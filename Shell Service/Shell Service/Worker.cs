using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Shell_Service
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly IHostApplicationLifetime _hostApplicationLifetime;
        private readonly IConfiguration _config;

        public Worker(ILogger<Worker> logger, IHostApplicationLifetime hostApplicationLifetime, IConfiguration configuration)
        {
            _logger = logger;
            _hostApplicationLifetime = hostApplicationLifetime;
            _config = configuration;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                var arguments = this._config.GetSection("WorkerSettings")?.GetSection("ScriptArguments")?.Value ?? "";
                var filename = this._config.GetSection("WorkerSettings")?.GetSection("Script")?.Value ?? "";
                await Task.Run(() => RunPowerShellScript($"{AppDomain.CurrentDomain.BaseDirectory}\\SupportingFiles\\{filename}", arguments, stoppingToken));
            }
            catch(Exception ex)
            {
                _logger.LogCritical(ex.Message);
            }
            finally
            {
                if (!stoppingToken.IsCancellationRequested)
                {
                    _logger.LogCritical("Exiting application...");
                }
                _hostApplicationLifetime.StopApplication();
            }
        }

        
        protected void RunPowerShellScript(string filename, string arguments, CancellationToken stoppingToken)
        {
            Process p = new Process();
            var output = new StringBuilder();
            var errors = new StringBuilder();
            // Redirect the output stream of the child process.
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.RedirectStandardError = true;
            p.StartInfo.RedirectStandardOutput = true;
            p.EnableRaisingEvents = true;
            p.StartInfo.FileName = "PowerShell.exe";
            var PSCommand = $"{{ &'{filename}' {arguments}; Exit $LastExitCode }}";
            p.StartInfo.Arguments = String.Format(@"-executionpolicy bypass -Command "" & {0}"" -Start", PSCommand);
            p.ErrorDataReceived += (s, d) => {
                errors.Append(d.Data);
            };
            // capture normal output
            p.OutputDataReceived += (s, d) => {
                output.Append(d.Data);
            };
            p.Start();
            p.BeginErrorReadLine();
            p.BeginOutputReadLine();

            // Wait for the completion of the script startup code,     // which launches the -Service instance.
            while (!stoppingToken.IsCancellationRequested && !p.HasExited) { };
            p.Kill();
            _logger.LogInformation(output.ToString());
            _logger.LogCritical(errors.ToString());
            return;
        }
    }
}
