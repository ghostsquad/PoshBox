namespace PoshBox.Parallel {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Management.Automation.Host;
    using System.Management.Automation.Runspaces;

    public class ParallelJobManager : IParallelJobManager {
        private RunspacePool runspacePool;

        private IList<RunspaceInvocationInfo> activeJobs = new List<RunspaceInvocationInfo>();

        public ParallelJobManager(int throttle, PSHost host) {
            var sessionState = InitialSessionState.CreateDefault();
            this.runspacePool = RunspaceFactory.CreateRunspacePool(1, throttle, sessionState, host);
        }

        public void ProcessNext(ScriptBlock scriptBlock, object inputObject) {
            throw new NotImplementedException();
        }

        public void ProcessNext(ScriptBlock scriptBlock, IDictionary parameterDictionary) {
            throw new NotImplementedException();
        }

        public void ProcessNext(ScriptBlock scriptBlock, IList parameterList) {
            throw new NotImplementedException();
        }

        public IEnumerable<RunspaceInvocationInfo> GetResults() {
            throw new NotImplementedException();
        }

        public void WaitForAll() {
            throw new NotImplementedException();
        }

        public void WaitForAll(int maxWait) {
            throw new NotImplementedException();
        }

        public bool Completed { get; private set; }
    }
}