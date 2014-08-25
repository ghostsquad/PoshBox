namespace PoshBox {
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Management.Automation;
    using System.Management.Automation.Language;
    using System.Text.RegularExpressions;

    public static class PowershellCaster {
        private static readonly Regex DefinitionRegex = new Regex(@"^[\w\d]+ ([\w\d]+\.)*[\w\d]+\((?<params>.*)\)$", RegexOptions.Compiled);
        private static readonly Regex ParamRegex = new Regex(@"^(?<paramtype>[\w\d\.]+) [\w\d]+$", RegexOptions.Compiled);

        private static List<Type> GetScriptMethodParams(ScriptBlock scriptblock) {
            var paramOrderedList = new List<Type>();
            var scriptBlockAst = scriptblock.Ast as ScriptBlockAst;
            if (scriptBlockAst == null) {
                return paramOrderedList;
            }

            if (scriptBlockAst.ParamBlock != null) {
                paramOrderedList.AddRange(
                    scriptBlockAst.ParamBlock.Parameters.Select(
                        blockParam => Type.GetType(blockParam.StaticType.FullName)));
            }

            return paramOrderedList;
        }

        private static List<Type> GetMethodParams(string definition) {
            var paramOrderedList = new List<Type>();

            var match = DefinitionRegex.Match(definition);
            if (!match.Success) {
                throw new InvalidDataException("found an unsupported method definition: " + definition);
            }

            if (!string.IsNullOrWhiteSpace(match.Groups["params"].Value)) {
                var paramsList = match.Groups["params"].Value.Split(',').Select(x => x.Trim());
                foreach (var paramDefinition in paramsList) {
                    var paramMatch = ParamRegex.Match(paramDefinition);
                    if (!paramMatch.Success) {
                        throw new InvalidDataException("found an unsupported parameter definition: " + paramDefinition);
                    }

                    paramOrderedList.Add(Type.GetType(paramMatch.Groups["paramtype"].Value));
                }
            }

            return paramOrderedList;
        }

        private static List<List<Type>> GetParamSets(PSMethodInfo method) {
            var methodasPsMethod = method as PSMethod;
            var methodasPsScriptMethod = method as PSScriptMethod;
            var paramSets = new List<List<Type>>();
            if (methodasPsMethod != null) {
                paramSets = method.OverloadDefinitions.Select(GetMethodParams).ToList();
            } else if (methodasPsScriptMethod != null) {
                paramSets.Add(GetScriptMethodParams(methodasPsScriptMethod.Script));
            } else {
                throw new NotImplementedException(
                    "method type: " + method.GetType().FullName + " not supported");
            }
            return paramSets;
        }

        private static bool MatchParamSets(List<List<Type>> paramSetsA, List<List<Type>> paramSetsB) {
            foreach (var paramSetA in paramSetsA) {
                foreach (var paramSetB in paramSetsB) {
                    if (paramSetA.SequenceEqual(paramSetB)) {
                        return true;
                    }
                }
            }

            return false;
        }

        public static void CheckCompatible(PSObject obj, PSObject definition, Type dynamicType) {
            if (definition == null) {
                throw new ArgumentException("Definition is null!");
            }
            if (obj == null) {
                throw new ArgumentException("Obj was null!");
            }

            foreach (var interfaceProperty in definition.Properties) {
                var found = false;
                foreach (var inheritorProperty in obj.Properties) {
                    if (inheritorProperty.IsInstance
                        && string.Equals(
                            interfaceProperty.Name,
                            inheritorProperty.Name,
                            StringComparison.OrdinalIgnoreCase)
                        && (interfaceProperty.Value as Type) == Type.GetType(inheritorProperty.TypeNameOfValue)) {

                        found = true;
                        break;
                    }
                }

                if (!found) {
                    throw new InvalidCastException("The object is not of type " + dynamicType + ". Missing property " + interfaceProperty.Name);
                }
            }

            foreach (var interfaceMethod in definition.Methods) {
                if (!interfaceMethod.IsInstance) {
                    continue;
                }
                var interfaceParamSets = GetParamSets(interfaceMethod);

                var found = false;
                foreach (var inheritorMethod in obj.Methods) {
                    if (inheritorMethod.IsInstance
                        && string.Equals(interfaceMethod.Name, inheritorMethod.Name, StringComparison.OrdinalIgnoreCase)) {

                        var inheritorParamSets = GetParamSets(inheritorMethod);
                        found = MatchParamSets(interfaceParamSets, inheritorParamSets);
                        if (found) {
                            break;
                        }
                    }
                }

                if (!found) {
                    throw new InvalidCastException("The object is not of type " + dynamicType + ". Missing method " + interfaceMethod.Name);
                }
            }
        }
    }
}
