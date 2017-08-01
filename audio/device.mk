#
# Copyright (C) 2014 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_PACKAGES := audio.primary.unknown

# These are not mandatory but are useful for debugging
PRODUCT_PACKAGES += \
    tinyplay \
    tinypcminfo \
    tinymix \
    stagefright

USE_XML_AUDIO_POLICY_CONF := 1

PRODUCT_COPY_FILES := \
			frameworks/av/services/audiopolicy/config/default_volume_tables.xml:system/etc/default_volume_tables.xml \
			$(LOCAL_PATH)/audio.unknown.xml:system/etc/audio.unknown.xml \
			$(LOCAL_PATH)/audio_policy_configuration.xml:system/etc/audio_policy_configuration.xml \
			$(LOCAL_PATH)/audio_policy_volumes.xml:system/etc/audio_policy_volumes.xml
