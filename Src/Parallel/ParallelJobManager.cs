namespace PoshBox.Parallel {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Management.Automation.Host;
    using System.Management.Automation.Runspaces;

    public class ParallelJobManager : IParallelJobManager {
        #region Fields

        private readonly Queue<IRunspaceInvocationInfo> jobs = new Queue<IRunspaceInvocationInfo>();

        private readonly RunspacePool runspacePool;

        private int totalJobs = 0;

        private int completedJobs = 0;

        private PSInvocationSettings psInvocationSettings = new PSInvocationSettings();

        #endregion

        #region Constructors and Destructors

        public ParallelJobManager(int throttle, PSHost host, int retryLimit = 0, bool useLocalScope = false) {
            var sessionState = InitialSessionState.CreateDefault();
            this.runspacePool = RunspaceFactory.CreateRunspacePool(1, throttle, sessionState, host);
        }

        #endregion

        #region Public Properties

        public bool Completed { get; private set; }

        #endregion

        #region Public Methods and Operators

        public void AddJob(ScriptBlock scriptBlock, object inputObject) {
            this.BootStrapRunspaceInvocationInfo(scriptBlock, inputObject);
        }

        public void AddJob(ScriptBlock scriptBlock, IDictionary inputObject) {
            this.BootStrapRunspaceInvocationInfo(scriptBlock, inputObject);
        }

        public void AddJob(ScriptBlock scriptBlock, IList inputObject) {
            this.BootStrapRunspaceInvocationInfo(scriptBlock, inputObject);
        }

        public void BeginProcessing() {
            while (this.jobs.Count > 0) {
                var nextJob = this.jobs.Dequeue();
                nextJob.PowerShellInstance.BeginInvoke(nextJob.Results, )
            }
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

        #endregion

        #region Methods

        private static readonly object JobCompletedSyncRoot = new object();

        private void JobCompleted() {
            lock (JobCompletedSyncRoot) {
                this.completedJobs++;
                if (this.completedJobs == this.totalJobs) {
                    
                }
            }
        }

        private void BootStrapRunspaceInvocationInfo(ScriptBlock scriptBlock, object inputObject) {
            this.totalJobs++;
            var powerShellInstance = PowerShell.Create().AddScript(scriptBlock.ToString());
            

            powerShellInstance.RunspacePool = this.runspacePool;
            var runspaceInvocationInfo = new RunspaceInvocationInfo {
                                                                        PowerShellInstance = powerShellInstance,
                                                                        InputObject = inputObject
                                                                    };

            TypeSwitch.Do(
                inputObject,
                TypeSwitch.Case<IDictionary>(x => powerShellInstance.AddParameters(x)),
                TypeSwitch.Case<IList>(x => powerShellInstance.AddParameters(x)),
                TypeSwitch.Default(x => powerShellInstance.AddArgument(x)));

            this.jobs.Enqueue(runspaceInvocationInfo);
        }

        #endregion
    }
}