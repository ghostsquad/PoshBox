# PoshBox

<img src="https://raw.githubusercontent.com/ghostsquad/PoshBox/master/Assets/poshbox.png" alt="PoshBox Logo" title="PoshBox" align="right" />

PoshBox is my <b>Po</b>wer<b>sh</b>ell Tool<b>Box</b>, similar to Powershell Community Extensions. In fact, PoshBox pulls various modules and code I've found, developed or improved upon all into one place. This isn't a "catch all". I'm trying to keep this module restricted to cmdlets and such that would be commonly used in any powershell development.

## Installation

1. Install [Powershell Community Extensions 3.1 or later](https://pscx.codeplex.com/releases)
2. Download the master branch zip
2. Extract to C:\Users\<YOU>\Documents\WindowsPowerShell\Modules
3. Run the following to import the module and verify:

    ```Powershell
    Import-Module C:\Users\USERNAME\Documents\WindowsPowerShell\Modules\PoshBox
    Get-Module PoshBox -ListAvailable
    ```
    
## Find out more

| **[Technical Docs] [techdocs]**     | **[Setup Guide] [setup]**     | **[Roadmap] [roadmap]**           | **[Contributing] [contributing]**           |
|-------------------------------------|-------------------------------|-----------------------------------|---------------------------------------------|
| [![i1] [techdocs-image]] [techdocs] | [![i2] [setup-image]] [setup] | [![i3] [roadmap-image]] [roadmap] | [![i4] [contributing-image]] [contributing] |

## Contributing

If you would like help implementing a new cmdlet, fixing a bug, or have an idea for something new, check out our **[Contributing] [contributing]** page on the wiki!

## Questions or need help?

Check out the **[Talk to us] [talk-to-us]** page on our wiki.

[wiki]: https://github.com/ghostsquad/poshbox/wiki
[talk-to-us]: https://github.com/ghostsquad/poshbox/wiki/Talk-to-us
[contributing]: https://github.com/ghostsquad/poshbox/wiki/Contributing
[license]: http://www.apache.org/licenses/LICENSE-2.0
[setup]: https://github.com/ghostsquad/poshbox/wiki/Setting-up-PoshBox
[tech-docs]: https://github.com/ghostsquad/poshbox/wiki/PoshBox%20technical%20documentation
[techdocs-image]: https://raw.githubusercontent.com/ghostsquad/PoshBox/master/Assets/TechArch.png
[setup-image]: https://raw.githubusercontent.com/ghostsquad/PoshBox/master/Assets/Setup.png
[roadmap-image]: https://raw.githubusercontent.com/ghostsquad/PoshBox/master/Assets/Roadmap.png
[contributing-image]: https://raw.githubusercontent.com/ghostsquad/PoshBox/master/Assets/Contributing.png

[techdocs]: https://github.com/ghostsquad/poshbox/wiki/PoshBox-technical-documentation
[setup]: https://github.com/ghostsquad/poshbox/wiki/Setting-up-PoshBox
[roadmap]: https://github.com/ghostsquad/poshbox/wiki/Product-roadmap
[contributing]: https://github.com/ghostsquad/poshbox/wiki/Contributing
