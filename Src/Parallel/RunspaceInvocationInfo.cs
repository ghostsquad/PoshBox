namespace PoshBox.Parallel {
    using System;
    using System.Management.Automation;

    public class RunspaceInvocationInfo : IRunspaceInvocationInfo {
        public PSDataCollection<PSObject> Results { get; set; }

        public object InputObject { get; set; }

        public double Runtime { get; set; }

        public IAsyncResult AsyncResult { get; set; }

        public PowerShell PowerShellInstance { get; set; }
    }
}