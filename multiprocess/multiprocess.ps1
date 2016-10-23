function initialise_multiprocess_starter()
{
  $source = @"
            using System;
            using System.Collections.Generic;
            using System.Diagnostics;


            public class MultiProcessExecutor
            {
                private System.Collections.Generic.List<string> m_processNames;
                private System.Collections.Generic.List<string> m_processArgs;
				private System.Collections.Generic.List<Process> m_processes;

                public MultiProcessExecutor()
                {
                    m_processNames = new System.Collections.Generic.List<string>();
                    m_processArgs = new System.Collections.Generic.List<string>();
					m_processes = new System.Collections.Generic.List<Process>();
                }

                public void add(string processName, string args)
                {
                    m_processNames.Add(processName);
                    m_processArgs.Add(args);
                }

                public void execute()
                {
                    for (int i = 0; i < m_processNames.Count; i++)
                    {
                        m_processes.Add(System.Diagnostics.Process.Start(m_processNames[i], m_processArgs[i]));
                    }
                }
				
				public void wait_for_all()
				{
					foreach(var process in m_processes)
                    {
                        process.WaitForExit();
                        process.Close();
                    }
				}

                public void kill_all()
				{
					foreach(var process in m_processes)
                    {
                        process.Kill();
                    }
				}

            }
"@

	Add-Type -TypeDefinition $source;
}

Clear-Host
initialise_multiprocess_starter

$process_executor = New-Object MultiProcessExecutor
<#
Add your processes by calling $process_executor.add( "" );
#>
$process_executor.execute()
# WAIT ENOUGH TIME AND :
$process_executor.wait_for_all()