# WSU Custom Course Module

This will serve as documentation for creating Blackboard building blocks and outlines the process used to build the WSU Custom Course Module (WSU CCM). Specific information about the CCM building block will also be presented.   

## Environment Setup

__note:__ Installation locations are included for example. The locations of your installed software may vary.

__note:__ powershell command for listing environmnet variables:

```
Get-ChildItem Env:
```

For viewing info on a particular environment variable:

```
$Env:Path
```

- [Creating environment variables](http://www.computerhope.com/issues/ch000549.htm)

##### Eclipse
- Download [Eclipse IDE for Java Developers](https://www.eclipse.org/downloads/packages/eclipse-ide-java-developers/lunasr1a)
- Install Web, XML, Java EE and OSGi Enterprise Development tools (Help > Install New Software > All Available Sites).
- Install the [Blackboard plugin](http://www.edugarage.com/display/BBDN/Building+Blocks+Eclipse+Plugin) (first 8 steps).
- Add the eclipse folder path (C:\bin\eclipse\;) to the Path environment variable.

##### Tomcat
- [Download Tomcat](http://tomcat.apache.org/)
- Ensure the base Tomcat directory (C:\Program Files\Apache Software Foundation\Tomcat 8.0) is stored as the `TOMCAT` environment variable.

##### Ant
- [Download Apache Ant](http://ant.apache.org/)
- Ensure ant installation directory (C:\apache-ant-1.9.4) is stored as `ANT_HOME` environment variable.

##### Blackboard Jars
- [Download](https://behind.blackboard.com/downloads/details.aspx?d=1691) the appropriate jar files for your environment. 
- Optional: add BBJarPath as an environment variable pointing to the systemlib directory (C:\bb-as-windows-9.1.201404.160205\payload\systemlib).

## Getting Started

##### Creating the Eclipse Project

- [Create a new Blackboard Project using the Blackboard Eclipse Plugin](http://www.edugarage.com/display/BBDN/Building+Blocks+Eclipse+Plugin)
- Can also start a new project using one of the [example projects](http://www.edugarage.com/display/BBDN/Sample+Code) from edugarage.
  - Import the zip/war file as a war (File > Import > Web > War File > Select the example project).

##### Configuring the classpath

- [Add a user library for the Tomcat Jars](http://www.avajava.com/tutorials/lessons/how-do-i-create-an-eclipse-user-library-for-the-tomcat-jar-files.html)
- Follow the same process to add a user library for the Blackboard Jars located systemlib folder. If you created the new eclipse project using the Blackboard eclipse plugin then this step has been done for you and may be skipped.  

##### Adding External Jars

- Add external jars to the WEB-INF/lib directory
- I commonly use the [gson](https://code.google.com/p/google-gson/) json (de)serializer.

##### Configuring the Ant build file

- If you created the project using the Blackboard eclipse plugin then your project should contain a build.xml file, if not then create the build.xml file. 
- I override the default build.xml file with my own standard [build file](https://gist.github.com/dworthen/a7c04ce0af6a9c725874).
  - Ensure that the src.dir and build.dir match the source and build directories as defined in the Project build path (right click on the project folder in the Project Explorer > Build Path > Configure Build Path > Source tab).
  - Update the b2.package.name to match your project name.
  
##### Develop!

- Begin developing content in the webContent directory.

##### Build

- [Open the Ant view and run the package-war task](http://www.tutorialspoint.com/ant/ant_eclipse_integration.htm)
- If package-war is set as the default task then the keyboard shortcut `Alt+Shift+X,Q` will build project.
- Building should create a new war file in the base directory of the project. 

##### Deploy

- Upload the war file to your Blackboard environment (System Admin > Building Blocks > Installed Tools > Upload).
- It is possible to automatically deploy to a development environment of Learn... We dont have a development environment setup so I cannot speak to that process.

## About the WSU Custom Course Module

The custom course module was built to address and solve several problems. 

- Separate SIS changes from course content changes. 
  - The overall concern was that it was possible for a department to delist a course thus deleting the course in Bb and therefore any content the instructor may created. 
  - Solution:
    - Students enroll into child sections and content is created in parent (master) spaces.
    - Child sections are not accessible by staff or students and content cannot be created in these spaces.
    - These child sections are referred to as "roster" spaces.
    - Changes made to courses by departments in SIS affect roster spaces but the parent space and the content within are unaffected. 
- Provide a central mechanism to faculty for managing courses.
  - Enable and Disable parent course spaces
  - Provide the ability to merge/separate rosters to parent spaces without providing instructors system level accounts

## Resources

- [Edugarage](http://www.edugarage.com/display/BBDN/Building+Blocks).
- [Building Block Api](https://help.blackboard.com/en-us/Learn/9.1_2014_04/Administrator/130_Building_Blocks/020_Developing_Building_Blocks/000_Building_Blocks_API_and_Web_Services_Specifications_and_Changes)
- [Sample code] (http://www.edugarage.com/display/BBDN/Sample+Code)
- [Blackboard Eclipse plugin](http://www.edugarage.com/display/BBDN/Building+Blocks+Eclipse+Plugin)
- [Blackboard Jars](https://behind.blackboard.com/downloads/details.aspx?d=1691)
- [Blackboard Taglib](http://library.blackboard.com/ref/b9696cc1-1d49-45f3-b8af-ce709f71b915/bbNG/tld-summary.html)
- [Default bbmanifest file for modules](https://gist.github.com/dworthen/ed90794cbd752f338823)
