# PoshBox

<img src="https://raw.githubusercontent.com/ghostsquad/PoshBox/master/Assets/poshbox.png" alt="PoshBox Logo" title="PoshBox" align="right" />

PoshBox is a Powershell library, similar to Powershell Community Extensions. Some of things inside:

1. **Logging** - Cmdlets that leverage Log4net
2. **Development helpers** - Source File Cleanup
  * TODO: PoshCop - Like StyleCop
3. **SQL/MYSQL** - Cmdlets to make querying SQL/MYSQL easier
4. **Indented!** - Including the [Indented! Module](http://www.indented.co.uk/)
5. **In-Console UI** - This is still under heavy development, but will include various ways to make a UI within the powershell console.

## Installation

1. Download the master branch zip
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
