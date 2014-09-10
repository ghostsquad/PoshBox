namespace PoshBox.Parallel {
    using System;
    using System.Management.Automation;

    public interface IRunspaceInvocationInfo : IRunspaceJobInfo {
        IAsyncResult AsyncResult { get; set; }

        PowerShell PowerShellInstance { get; set; }
    }
}