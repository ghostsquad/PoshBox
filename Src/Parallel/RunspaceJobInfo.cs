namespace PoshBox.Parallel {
    using System.Management.Automation;

    public class RunspaceJobInfo : IRunspaceJobInfo {
        public RunspaceJobInfo(IRunspaceInvocationInfo invocationInfo) {
            this.Results = invocationInfo.Results;
            this.InputObject = invocationInfo.InputObject;
            this.Runtime = invocationInfo.Runtime;
        }

        public PSDataCollection<PSObject> Results { get; set; }

        public object InputObject { get; set; }

        public double Runtime { get; set; }
    }
}
