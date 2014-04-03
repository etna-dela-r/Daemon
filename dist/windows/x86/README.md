Building Windows installer
==========================
Here are the sources from the Shunt installer.

To build the MSI installer file, you will need Wix Toolset available at http://wixtoolset.org/releases/

Using Command line
------------------
	%PathToWixToolset%\bin\candle.exe %ShuntFile%.xml -out %ShuntFile%.wixobj
	%PathToWixToolset%\bin\light.exe %ShuntFile%.xml -ext WixUIExtension -out %ShuntFile%.msi

Using Wixedit
-------------
Wixedit is an editor reading XML files to build MSI files. you can download it here : http://wixedit.sourceforge.net/

Once it is installed, open the XML file with it and chosse the 'Build MSI setup package' option in the 'Build' tab, or hit Ctrl+B
