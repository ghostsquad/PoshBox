namespace PoshBox.Parallel {
    using System.Collections;
    using System.Collections.Generic;
    using System.Management.Automation;

    public interface IParallelJobManager {
        void ProcessNext(ScriptBlock scriptBlock, object inputObject);

        void ProcessNext(ScriptBlock scriptBlock, IDictionary parameterDictionary);

        void ProcessNext(ScriptBlock scriptBlock, IList parameterList);

        IEnumerable<RunspaceInvocationInfo> GetResults();

        void WaitForAll();

        void WaitForAll(int maxWait);

        bool Completed { get; }
    }
}
