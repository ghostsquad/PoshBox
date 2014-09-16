namespace PoshBox.Parallel {
    using System.Collections;
    using System.Collections.Generic;
    using System.Management.Automation;
    using System.Security.Cryptography.X509Certificates;

    public interface IParallelJobManager {
        void AddJob(ScriptBlock scriptBlock, object inputObject);

        void AddJob(ScriptBlock scriptBlock, IDictionary parameterDictionary);

        void AddJob(ScriptBlock scriptBlock, IList parameterList);

        void BeginProcessing();

        IEnumerable<RunspaceInvocationInfo> GetResults();

        void WaitForAll();

        void WaitForAll(int maxWait);

        bool Completed { get; }
    }
}
