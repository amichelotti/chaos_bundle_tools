## Andrea Michelotti
## 29/8/2016
SET(CHAOS_BUNDLE ${CMAKE_CURRENT_LIST_DIR})
cmake_minimum_required(VERSION 2.8.9)
include(chaosframework/config/CMakeChaos.txt)
option(CHAOS_VME "Vme Support" ON)
project(chaos)
ADD_DEFINITIONS(-DCHAOS)
# ### framework

ADD_SUBDIRECTORY(chaosframework)

# ### common
 ADD_SUBDIRECTORY(common/debug)
 ADD_SUBDIRECTORY(common/misc)
 ADD_SUBDIRECTORY(common/crest)
 IF(CHAOS_VME)
  ADD_SUBDIRECTORY(common/vme)
 ENDIF()	
 ADD_SUBDIRECTORY(common/serial)
 ADD_SUBDIRECTORY(common/modbus)
 ADD_SUBDIRECTORY(common/powersupply)
 ADD_SUBDIRECTORY(common/actuators)
 ADD_SUBDIRECTORY(common/test)

# ## DRIVERS
 ADD_SUBDIRECTORY(driver/misc)
 ADD_SUBDIRECTORY(driver/powersupply)
 ADD_SUBDIRECTORY(driver/sensors)
# ADD_SUBDIRECTORY(driver/plc)
# ADD_SUBDIRECTORY(driver/oscilloscopes)
 ADD_SUBDIRECTORY(driver/daq)
 ADD_SUBDIRECTORY(driver/data-import)
 ADD_SUBDIRECTORY(driver/modbus)
 ADD_SUBDIRECTORY(driver/actuator)
#  ADD_SUBDIRECTORY(driver/eu/eledia-eu)
 
 ###
## ADD_SUBDIRECTORY(service/webgui/CUiserver)
InstallChaos()
INSTALL(DIRECTORY tools DESTINATION ${CMAKE_INSTALL_PREFIX} PATTERN "*" PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ)

