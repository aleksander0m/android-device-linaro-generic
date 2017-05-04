/*
 * Copyright (C) 2008 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "lights"

#include <cutils/log.h>

#include <malloc.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <dirent.h>
#include <stdbool.h>

#include <sys/ioctl.h>
#include <sys/types.h>

#include <hardware/lights.h>
#include <hardware/hardware.h>

char const* const BACKLIGHT_PATH_BASE = "/sys/class/backlight/";

char backlight_path[1024];

long brightness_max;

static int write_int(char const *path, int value)
{
	int fd;
	static bool already_warned = false;

	fd = open(path, O_RDWR);
	if (fd >= 0) {
		char buffer[20];
		int bytes = snprintf(buffer, 20, "%d\n", value);
		int amt = write(fd, buffer, bytes);

		close(fd);
		return amt == -1 ? -errno : 0;
	} else {
		if (!already_warned) {
			already_warned = true;
			ALOGE("write_int failed to open %s\n", path);
		}
		return -errno;
	}
}

static int read_int(char const *path)
{
	char buffer[20];
	int amt;
	int fd = open(path, O_RDONLY);
	if (fd < 0)
		return -errno;

	amt = read(fd, buffer, 20);
	if (amt > 0)
		return atoi(buffer);
	return -1;
}

static int rgb_to_brightness(struct light_state_t const *state)
{
	int color = state->color & 0x00ffffff;
	return ((77 * ((color >> 16) & 0x00ff))
			+ (150 * ((color >> 8) & 0x00ff)) +
			(29 * (color & 0x00ff))) >> 8;
}


static int normalize_brightness(int brightness, int max_brightness)
{
	int ret;

	/*
	 * API specifies argb which we convert to a 8bit
	 * brightness value. This function then normalizes it
	 * to the max_brightness range given
	 */
	ret = brightness * max_brightness;
	ret = ret / 255;

	return ret;
}

static int set_light_backlight(struct light_device_t *dev,
		struct light_state_t const *state)
{
	char brightness_path[1024];
	int err;
	int brightness;

	snprintf(brightness_path, 1024, "%s/brightness", backlight_path);
	brightness = rgb_to_brightness(state);
	brightness = normalize_brightness(brightness, brightness_max);
	err = write_int(brightness_path, brightness);

	return err;
}

/** Close the lights device */
static int close_lights(struct light_device_t *dev)
{
	if (dev)
		free(dev);
	return 0;
}

/** Open a new instance of a lights device using name */
static int open_lights(const struct hw_module_t *module, char const *name,
		struct hw_device_t **device)
{
	struct light_device_t *dev = malloc(sizeof(struct light_device_t));
	int (*set_light) (struct light_device_t *dev,
			struct light_state_t const *state);
	DIR *dir;
	struct dirent *entry;
	char buffer[1024];

	if (dev == NULL) {
		ALOGE("failed to allocate memory");
		return -1;
	}
	memset(dev, 0, sizeof(*dev));

	if (0 == strcmp(LIGHT_ID_BACKLIGHT, name))
		set_light = set_light_backlight;
	else
		return -EINVAL;


	if(!(dir = opendir(BACKLIGHT_PATH_BASE)))
		return -EINVAL;
	if (!(entry = readdir(dir)))
		return -EINVAL;

	do {
		if (entry->d_type == DT_DIR) {
			continue;
		}
		sprintf(backlight_path, "%s%s", BACKLIGHT_PATH_BASE, entry->d_name);
	} while (entry = readdir(dir));
	closedir(dir);

	ALOGI("backlight path: %s\n", backlight_path);

	snprintf(buffer, 1024, "%s/max_brightness", backlight_path);
	brightness_max = read_int(buffer);

	if (brightness_max <= 0)
		ALOGE("invalid max brightness: %ld\n", brightness_max);
	else
		ALOGI("max brightness set: %ld\n", brightness_max);

	dev->common.tag = HARDWARE_DEVICE_TAG;
	dev->common.version = 0;
	dev->common.module = (struct hw_module_t *)module;
	dev->common.close = (int (*)(struct hw_device_t *))close_lights;
	dev->set_light = set_light;

	*device = (struct hw_device_t *)dev;

	return 0;
}

static struct hw_module_methods_t lights_methods =
{
	.open =  open_lights,
};

/*
 * The backlight Module
 */
struct hw_module_t HAL_MODULE_INFO_SYM =
{
	.tag = HARDWARE_MODULE_TAG,
	.version_major = 1,
	.version_minor = 0,
	.id = LIGHTS_HARDWARE_MODULE_ID,
	.name = "Flo/mainline lights module",
	.author = "NVIDIA,Linaro",
	.methods = &lights_methods,
};
