namespace PoshBox {
    using System;
    using System.Linq;

    internal static class TypeSwitch {
        #region Public Methods and Operators

        public static CaseInfo Case<T>(Action action) {
            return new CaseInfo { Action = x => action(), Target = typeof(T) };
        }

        public static CaseInfo Case<T>(Action<T> action) {
            return new CaseInfo { Action = x => action((T)x), Target = typeof(T) };
        }

        public static CaseInfo Default(Action action) {
            return new CaseInfo { Action = x => action(), IsDefault = true };
        }

        public static CaseInfo Default(Action<object> action) {
            return new CaseInfo { Action = action, IsDefault = true };
        }

        public static void Do(object source, params CaseInfo[] cases) {
            var type = source.GetType();
            foreach (var entry in cases.Where(entry => entry.IsDefault || entry.Target.IsAssignableFrom(type))) {
                entry.Action(source);
                break;
            }
        }

        #endregion

        public class CaseInfo {
            #region Public Properties

            public Action<object> Action { get; set; }

            public bool IsDefault { get; set; }

            public Type Target { get; set; }

            #endregion
        }
    }
}