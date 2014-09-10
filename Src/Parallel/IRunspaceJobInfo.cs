namespace PoshBox.Parallel {
    using System.Management.Automation;

    public interface IRunspaceJobInfo {
        PSDataCollection<PSObject> Results { get; set; }

        object InputObject { get; set; }

        double Runtime { get; set; }
    }
}
