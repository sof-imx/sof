#
# Topology for Icelake with rt711 + rt1308 (x2) + rt715.
#

# Include topology builder
include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')

# Include TLV library
include(`common/tlv.m4')

# Include Token library
include(`sof/tokens.m4')

# Include ICL DSP configuration
include(`platform/intel/icl.m4')

DEBUG_START

#
# Define the pipelines
#
# PCM0 ---> volume ----> ALH 2 BE dailink 0
# PCM1 <--- volume <---- ALH 3 BE dailink 1
# PCM2 ---> volume ----> ALH 2 BE dailink 2
# PCM3 ---> volume ----> ALH 2 BE dailink 3
# PCM4 <--- volume <---- ALH 2 BE dailink 4

dnl PIPELINE_PCM_ADD(pipeline,
dnl     pipe id, pcm, max channels, format,
dnl     period, priority, core,
dnl     pcm_min_rate, pcm_max_rate, pipeline_rate,
dnl     time_domain, sched_comp)

# Low Latency playback pipeline 1 on PCM 0 using max 2 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-playback.m4,
	1, 0, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

# Low Latency capture pipeline 2 on PCM 1 using max 2 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-capture.m4,
	2, 1, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

# Low Latency playback pipeline 3 on PCM 2 using max 2 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-playback.m4,
	3, 2, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

# Low Latency playback pipeline 4 on PCM 3 using max 2 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-playback.m4,
	4, 3, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

# Low Latency capture pipeline 5 on PCM 4 using max 2 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-highpass-capture.m4,
	5, 4, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

#
# DAIs configuration
#

dnl DAI_ADD(pipeline,
dnl     pipe id, dai type, dai_index, dai_be,
dnl     buffer, periods, format,
dnl     deadline, priority, core, time_domain)

# playback DAI is ALH(SDW0 PIN2) using 2 periods
# Buffers use s24le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	1, ALH, 2, SDW0-Playback,
	PIPELINE_SOURCE_1, 2, s24le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# capture DAI is ALH(SDW0 PIN2) using 2 periods
# Buffers use s24le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	2, ALH, 3, SDW0-Capture,
	PIPELINE_SINK_2, 2, s24le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# playback DAI is ALH(SDW1 PIN2) using 2 periods
# Buffers use s24le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	3, ALH, 0x102, SDW1-Playback,
	PIPELINE_SOURCE_3, 2, s24le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# playback DAI is ALH(SDW2 PIN2) using 2 periods
# Buffers use s24le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	4, ALH, 0x202, SDW2-Playback,
	PIPELINE_SOURCE_4, 2, s24le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# capture DAI is ALH(SDW3 PIN2) using 2 periods
# Buffers use s24le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	5, ALH, 0x302, SDW3-Capture,
	PIPELINE_SINK_5, 2, s24le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)


# PCM Low Latency, id 0
dnl PCM_PLAYBACK_ADD(name, pcm_id, playback)
PCM_PLAYBACK_ADD(Headphone, 0, PIPELINE_PCM_1)
PCM_CAPTURE_ADD(Headset mics, 1, PIPELINE_PCM_2)
PCM_PLAYBACK_ADD(SDW1-speakers, 2, PIPELINE_PCM_3)
PCM_PLAYBACK_ADD(SDW2-speakers, 3, PIPELINE_PCM_4)
PCM_CAPTURE_ADD(Microphones, 4, PIPELINE_PCM_5)

#
# BE configurations - overrides config in ACPI if present
#

#ALH dai index = ((link_id << 8) | PDI id)
#ALH SDW0 Pin2 (ID: 0)
DAI_CONFIG(ALH, 2, 0, SDW0-Playback)

#ALH SDW0 Pin3 (ID: 1)
DAI_CONFIG(ALH, 3, 1, SDW0-Capture)

#ALH SDW1 Pin2 (ID: 2)
DAI_CONFIG(ALH, 0x102, 2, SDW1-Playback)

#ALH SDW2 Pin2 (ID: 3)
DAI_CONFIG(ALH, 0x202, 3, SDW2-Playback)

#ALH SDW3 Pin2 (ID: 4)
DAI_CONFIG(ALH, 0x302, 4, SDW3-Capture)

DEBUG_END
