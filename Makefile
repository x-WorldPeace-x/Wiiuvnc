BASEDIR	:= $(dir $(firstword $(MAKEFILE_LIST)))
VPATH	:= $(BASEDIR)

#---------------------------------------------------------------------------------
# TARGET is the name of the output
# BUILD is the directory where object files & intermediate files will be placed
# SOURCES is a list of directories containing source code
# INCLUDES is a list of directories containing header files
# ROMFS is a directory that will be available as romfs:/
#---------------------------------------------------------------------------------
TARGET		:=	wiiu-vnc
BUILD		:=	build
SOURCES		:=	src
INCLUDES	:=	include \
				libvncclient/common \
				libvncclient
ROMFS		:=	
LIBS		:=	sdl2 SDL2_gfx SDL2_image SDL2_mixer SDL2_ttf freetype2 libpng libmpg123 vorbisidec libjpeg zlib libpng

# libvncclient
OBJECTS		+=	\
    libvncclient/tls_none.o \
    libvncclient/cursor.o \
    libvncclient/listen.o \
    libvncclient/rfbproto.o \
    libvncclient/sockets.o \
    libvncclient/vncviewer.o \
	libvncclient/common/turbojpeg.o \
	libvncclient/common/minilzo.o

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
CFLAGS		+=	-O2 -include "rfb/rfbconfig.h"
CXXFLAGS	+=	-O2

#---------------------------------------------------------------------------------
# libraries
#---------------------------------------------------------------------------------
PKGCONF			:=	$(DEVKITPRO)/portlibs/wiiu/bin/powerpc-eabi-pkg-config
CFLAGS			+=	`$(PKGCONF) --cflags $(LIBS)`
CXXFLAGS		+=	`$(PKGCONF) --cflags $(LIBS)`
LDFLAGS			+=	`$(PKGCONF) --libs $(LIBS)`

#---------------------------------------------------------------------------------
# wut libraries
#---------------------------------------------------------------------------------
LDFLAGS		+=	$(WUT_NEWLIB_LDFLAGS) $(WUT_STDCPP_LDFLAGS) $(WUT_DEVOPTAB_LDFLAGS) \
				-lcoreinit -lvpad -lsndcore2 -lsysapp -lnsysnet -lnlibcurl -lproc_ui -lgx2 -lgfd -lwhb \

#---------------------------------------------------------------------------------
# romfs
#---------------------------------------------------------------------------------
include $(DEVKITPRO)/portlibs/wiiu/share/romfs-wiiu.mk
CFLAGS		+=	$(ROMFS_CFLAGS)
CXXFLAGS	+=	$(ROMFS_CFLAGS)
LDFLAGS		+=	$(ROMFS_LDFLAGS)
OBJECTS		+=	$(ROMFS_TARGET)

#---------------------------------------------------------------------------------
# includes
#---------------------------------------------------------------------------------
CFLAGS		+=	$(foreach dir,$(INCLUDES),-I$(dir))
CXXFLAGS	+=	$(foreach dir,$(INCLUDES),-I$(dir))

#---------------------------------------------------------------------------------
# generate a list of objects
#---------------------------------------------------------------------------------
CFILES		:=	$(foreach dir,$(SOURCES),$(wildcard $(dir)/*.c))
CPPFILES	:=	$(foreach dir,$(SOURCES),$(wildcard $(dir)/*.cpp))
SFILES		:=	$(foreach dir,$(SOURCES),$(wildcard $(dir)/*.S))
OBJECTS		+=	$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.S=.o)

#---------------------------------------------------------------------------------
# targets
#---------------------------------------------------------------------------------
$(TARGET).rpx: $(OBJECTS)

clean:
	$(info clean ...)
	@rm -rf $(TARGET).rpx $(OBJECTS) $(OBJECTS:.o=.d)

.PHONY: clean

#---------------------------------------------------------------------------------
# wut
#---------------------------------------------------------------------------------
include $(WUT_ROOT)/share/wut.mk
