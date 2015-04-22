package helper.buildingblock;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

import blackboard.platform.plugin.PlugInException;
import blackboard.platform.plugin.PlugInUtil;

/**
 * This is a helper class for your building block. Feel free to modify it to meet the needs
 * of this building block. 
 *
 */
public class BuildingBlockHelper {
	
	/** 
	 * The vendor ID for the Building Block. This must match the vendor ID in the
	 * bb-manifest.xml file.
	 */
	public static final String VENDOR_ID = "wsu";
	/** 
	 * The vendor ID for the Building Block. This must match the building block "handle"
	 * in the bb-manifest.xml file.
	 */
	public static final String HANDLE = "wsu-custom-course-module";
	/** The name of the building block settings file in the config directory */
	public static final String SETTINGS_FILE_NAME = "settings.properties";
	public static final String BUILD_FILE_NAME = "build.properties";
	
	/** 
	 * Returns the config directory for this Building Block 
	 *  
	 * @return
	 * @throws PlugInException
	 */
	public static File getConfigDirectory() throws PlugInException {
		File configDir = PlugInUtil.getConfigDirectory(VENDOR_ID, HANDLE);
		if (!configDir.exists()) {
			configDir.mkdir();
		}
		return configDir;
	}
	
	public static String getBaseUrl() {
		return PlugInUtil.getUri(VENDOR_ID, HANDLE, "");
	}
	
	public static String getBaseUrl(String resource) {
		return PlugInUtil.getUri(VENDOR_ID, HANDLE, resource);
	}
	
	public static Properties loadBuildProperties() throws IOException {
		File settingsFile = new File(getBaseUrl(BUILD_FILE_NAME));
//		if (!settingsFile.exists()) {
//			settingsFile.createNewFile();
//		}
		FileInputStream in = new FileInputStream(settingsFile);
		Properties settings = new Properties();
		settings.load(in);
		in.close();
		return settings;
	}
	
	/** 
	 * Loads the settings file for the Building block. 
	 * 
	 * @return
	 * @throws PlugInException
	 * @throws IOException
	 */
	public static Properties loadBuildingBlockSettings() throws PlugInException, IOException {
		File settingsFile = new File(getConfigDirectory(), SETTINGS_FILE_NAME);
		if (!settingsFile.exists()) {
			settingsFile.createNewFile();
		}
		FileInputStream in = new FileInputStream(settingsFile);
		Properties settings = new Properties();
		settings.load(in);
		in.close();
		return settings;
	}
	
	/** 
	 * Saves the building block settings.
	 * @param props
	 * @throws PlugInException
	 * @throws IOException
	 */
	public static void saveBuildingBlockSettings(Properties props) throws PlugInException, IOException {
		File settingsFile = new File(getConfigDirectory(), SETTINGS_FILE_NAME);
		if (!settingsFile.exists()) {
			settingsFile.createNewFile();
		}
		FileOutputStream out = new FileOutputStream(settingsFile);
		props.store(out, "Building Block Properties File");
		out.close();
	}
	
}
