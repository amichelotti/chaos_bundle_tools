## Andrea Michelotti
## 29/8/2016
cmake_minimum_required(VERSION 2.8.9)
include(chaosframework/config/CMakeChaos.txt)

project(chaos)
ADD_DEFINITIONS(-DCHAOS)
# ### framework

ADD_SUBDIRECTORY(chaosframework)

# ### common
 ADD_SUBDIRECTORY(common/debug)
 ADD_SUBDIRECTORY(common/misc)
 ADD_SUBDIRECTORY(common/crest)
 ADD_SUBDIRECTORY(common/vme)
 ADD_SUBDIRECTORY(common/serial)
 ADD_SUBDIRECTORY(common/modbus)
 ADD_SUBDIRECTORY(common/powersupply)
 ADD_SUBDIRECTORY(common/actuators)
 ADD_SUBDIRECTORY(common/test)

# ## DRIVERS
 ADD_SUBDIRECTORY(driver/misc)
 ADD_SUBDIRECTORY(driver/powersupply)
 ADD_SUBDIRECTORY(driver/sensors)
 ADD_SUBDIRECTORY(driver/plc)
 ADD_SUBDIRECTORY(driver/oscilloscopes)
 ADD_SUBDIRECTORY(driver/daq)
 ADD_SUBDIRECTORY(driver/data-import)
 ADD_SUBDIRECTORY(driver/chaos-mess)
 ADD_SUBDIRECTORY(driver/modbus)
# RETURN()
