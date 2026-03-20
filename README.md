# Windows Cleanup Utility

Batch script for analyzing and cleaning common Windows junk-data locations.

## Functions

- **Quick scan of common junk locations**  
  Shows typical cleanup targets such as user temp, Windows temp, Prefetch, Windows Update cache, and thumbnail cache.

- **Detailed scan with sizes**  
  Displays file count, total size, and last change date for common junk locations.

- **Clean user temp**  
  Removes files from the current user's temp folder.

- **Clean Windows temp**  
  Removes files from the Windows temp directory.

- **Clean Prefetch**  
  Removes files from the Prefetch folder.

- **Empty recycle bin**  
  Clears the Windows recycle bin.

- **Clean Windows Update cache**  
  Stops update services, clears the SoftwareDistribution download cache, and starts services again.

- **Flush DNS cache**  
  Clears the local DNS resolver cache.

- **Clean thumbnail cache**  
  Removes Windows thumbnail cache files.

- **Run all standard cleanups**  
  Executes the main cleanup actions in one run.

- **Report generation**  
  Creates a TXT report in:
  `Desktop\CleanupReports`

- **Open report folder**  
  Opens the cleanup report directory in Explorer.

## Notes

- Administrator rights are required for Windows temp, Prefetch, and Windows Update cache cleanup.
- Some files may remain if they are locked by running processes.
- The script is designed to analyze first and clean on demand.
