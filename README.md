# WSU Custom Course Module

This will serve as documentation for creating Blackboard building blocks and outlines the process used to develop the WSU Custom Course Module (WSU CCM).    

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
- [Download](https://behind.blackboard.com/downloads/details.aspx?d=1691) the appropriate environment files. 
- Optional: add BBJarPath as an environment variable pointing to the systemlib directory (C:\bb-as-windows-9.1.201404.160205\payload\systemlib).

## Getting Started

##### Creating the Eclipse Project

- [Create a new Blackboard Project using the Blackboard Eclipse Plugin](http://www.edugarage.com/display/BBDN/Building+Blocks+Eclipse+Plugin)
- Can also start a new project using one of the [example projects](http://www.edugarage.com/display/BBDN/Sample+Code) from edugarage.
  - Import the zip/war file as a war (File > Import > Web > War File > Select the example project).

##### Configuring the classpath

- [Add a user library for the Tomcat Jars](http://www.avajava.com/tutorials/lessons/how-do-i-create-an-eclipse-user-library-for-the-tomcat-jar-files.html)
- Follow the same process to add a user library for the Blackboard Jars located systemlib folder. If you created the new eclipse project using the Blackboard eclipse plugin then this step has been done for you and may be skipped.  

##### bb-manifest.xml

- Building block projects require a bb-manifest.xml file in the webContent/WEB-INF directory. This should already exist if the eclipse plugin was used to create the project or if the project was created using a sample project. 
- [Example manifest for portal/module building blocks](https://gist.github.com/dworthen/ed90794cbd752f338823)
  - Update the ALLCAPS attribute values with project specific values.

##### Adding External Jars

- Add external jars to the WEB-INF/lib directory
- I commonly use the [gson](https://code.google.com/p/google-gson/) json (de)serializer.

##### Configuring the Ant build file

- If you created the project using the Blackboard eclipse plugin then your project should contain a build.xml file, if not then create the build.xml file. 
- I override the default build.xml file with my own standard [ant build file](https://gist.github.com/dworthen/a7c04ce0af6a9c725874).
  - Ensure that the src.dir and build.dir match the source and build directories as defined in the Project build path (right click on the project folder in the Project Explorer > Build Path > Configure Build Path > Source tab).
  - Ensure the web.dir value matches the webContent directory of your project (depending on how the project was created you may have a webContent directory or a WebContent directory).
  - Update the b2.package.name value with the project name.
  - My default project settings: default source: PROJECT-DIRECTORY/src, default build: PROJECT-DIRECTORY/build/classes.
  
##### Develop!

- Begin developing content in the webContent directory.
- The [building block](https://help.blackboard.com/en-us/Learn/9.1_2014_04/Administrator/130_Building_Blocks/020_Developing_Building_Blocks/000_Building_Blocks_API_and_Web_Services_Specifications_and_Changes) and [taglib](http://library.blackboard.com/ref/b9696cc1-1d49-45f3-b8af-ce709f71b915/bbNG/tld-summary.html) api will help.

##### Build

- [Open the Ant view and run the package-war task](http://www.tutorialspoint.com/ant/ant_eclipse_integration.htm)
- If package-war is set as the default task then the keyboard shortcut `Alt+Shift+X,Q` will build project.
- Building should create a new war file in the base directory of the project. 
- Ensure you build for the correct target environment. At the time of this writing the target environment was Java 1.5. To update the target build environment right click the project > Build Path > Configure Build Path > Libraries tab > Select JRE System Library > Edit > Select Execution environment and select the appropriate environment from the dropdown (JSE-1.5 (jre1.8.0_20)).

##### Deploy

- Upload the war file to your Blackboard environment (System Admin > Building Blocks > Installed Tools > Upload).
- It is possible to automatically deploy to a development environment of Learn... We dont have a development environment setup so I cannot speak to that process.

## About the WSU Custom Course Module

The custom course module was built to address and solve several problems. 

- Separate SIS changes from course content changes. 
  - The overall concern was in regards to the ability for a department to make course changes which would feed into Learn through the SIS integration and affect any content created by the instructor. Example, delisting a course in SIS would delete the course and any corresponding content in Learn.    
  - Solution:
    - Students enroll into child sections and content is created in a parent (master) space.
    - Child sections are not accessible by staff or students and content cannot be created in these spaces.
    - The child sections are referred to as "roster" spaces while the parent spaces are referred to as "content" spaces.
    - Course changes in SIS affect roster spaces but the content spaces and the content within are unaffected. 
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
- [Example ant build file](https://gist.github.com/dworthen/a7c04ce0af6a9c725874)
- [Example bbmanifest file for creating modules](https://gist.github.com/dworthen/ed90794cbd752f338823)

##### Additional Resources

- [Java tutorial](http://www.tutorialspoint.com/java/)
- [Ant tutorial](http://www.tutorialspoint.com/ant/)
- [Git integration with eclipse](http://www.vogella.com/tutorials/EclipseGit/article.html)
- [Java web development](http://www.vogella.com/tutorials/EclipseWTP/article.html)
