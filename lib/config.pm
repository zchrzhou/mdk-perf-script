package config;

use Cwd;
use sample;
use FindBin;

require Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = qw(%conf, %test_map, %msdk_sample_map);

our %conf = (
    "verbose_flag"    => 1,
    "debug_flag"      => 0,

    "input_dir"       => "input",
    "output_dir"      => "output",
    "input_cp_flag"   => 0,
    "output_flag"     => 0, # only for Linux

    "cpu_cal_flag"    => 0,
    "gpu_cal_flag"    => 0,
    "fps_cal_flag"    => 0,
    "gpu_log_name"    => "gpu.log",
    "par_use_flag"    => 0,

    "steam_dir"       => "$FindBin::Bin/stream",
    "sample_bin_path" => "$FindBin::Bin/binary",
    "tools_dir"       => "$FindBin::Bin/tools",

    "ld_so_path"      => "/opt/intel/mediasdk/lib64:/opt/intel/common/mdf/lib64:/opt/intel/opencl",

    "range_template"  => ["LP%02d-H264", "transcode", "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -b 10000 -f 30 -u 7 -priority 2 -async 4"],
);

### Test Map
##Transcode: ITEM => [channel-num, test-type, input-codec, input-file, output-codex, output-ext, head-args, tail-args]
##Decode:    ITEM => [channel-num, test-type, input-param, input-file, output-param, output-ext, head-args, tail-args]
##Encode:    ITEM => [channel-num, test-type, input-param, input-file, output-param, output-ext, head-args, tail-args]
##VPP:       ITEM => [channel-num, test-type, input-param, input-file, output-param, output-ext, head-args, tail-args]
our %test_map = (
    "A01" => [1,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A02" => [2,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A03" => [3,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A04" => [4,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A05" => [5,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A06" => [6,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A07" => [7,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A08" => [8,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A09" => [9,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A10" => [10, "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "A11" => [11, "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],

    "B1"  => [5,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1280 -h 720 -u 7 -b 2048"],
    "B2"  => [5,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 720  -h 480 -u 7 -b 1024"],
    "B3"  => [5,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 352  -h 288 -u 7 -b 800" ],
    "B4"  => [5,  "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 176  -h 144 -u 7 -b 80"  ],

    "C1"  => [1,  "transcode",  "-i::mpeg2", "1080p.m2t", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 6000"],
    "C2"  => [1,  "transcode",  "-i::mpeg2", "1080p.m2t", "-o::h264", "h264", "", "-hw -w 1280 -h 720  -u 7 -b 2048"],
    "C3"  => [2,  "transcode",  "-i::mpeg2", "1080p.m2t", "-o::h264", "h264", "", "-hw -w 720  -h 480  -u 7 -b 1024"],
    "C4"  => [3,  "transcode",  "-i::mpeg2", "1080p.m2t", "-o::h264", "h264", "", "-hw -w 352  -h 288  -u 7 -b 800" ],
    "C5"  => [4,  "transcode",  "-i::mpeg2", "1080p.m2t", "-o::h264", "h264", "", "-hw -w 176  -h 144  -u 7 -b 80"  ],

    "D1"  => [2,  "decode", "-i", "JOY_1080.h264", "-o", "yuv",  "h264", "-hw" ],
    "D2"  => [6,  "decode", "-i", "JOY_1080.h264", "-o", "yuv",  "h264", "-hw" ],
    "D3"  => [2,  "decode", "-i", "JOY_1080.h264", "-r", "",     "h264", "-hw" ],
    "D4"  => [3,  "decode", "-i", "JOY_1080.h264", "",   "",     "h264", "-hw" ],

    "E1"  => [2,  "encode", "-i", "JOY_1080.yuv", "-o", "h264", "h264", "-hw -w 1920  -h 1080" ],
    "E2"  => [6,  "encode", "-i", "JOY_1080.yuv", "-o", "h264", "h264", "-hw -w 1920  -h 1080" ],

    "F1"  => [2,  "vpp", "-i", "JOY_1080.yuv", "-o", "yuv", "-lib hw", "-scc nv12 -dcc nv12 -sw 1920  -sh 1080 -dw 1280  -dh 720 -n 5" ],

    "V0"  => [16, "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 15000"],
    "V1"  => [16, "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 15000"],
    "V2"  => [16, "transcode",  "-i::h264", "1080p.h264", "-o::h264", "h264", "", "-hw -w 1920 -h 1080 -u 7 -b 15000"],

    ## This is for VCA demo
    "node0" => [17, "transcode",  "-i::h264", "1080p-0.h264", "-o::h264", "h264", "-p /VCA/perf-script/output/avc-fps-0.log", "-hw -b 10000 -f 30 -u 7 -priority 2 -async 4"],
    "node1" => [17, "transcode",  "-i::h264", "1080p-1.h264", "-o::h264", "h264", "-p /VCA/perf-script/output/avc-fps-1.log", "-hw -b 10000 -f 30 -u 7 -priority 2 -async 4"],
    "node2" => [17, "transcode",  "-i::h264", "1080p-2.h264", "-o::h264", "h264", "-p /VCA/perf-script/output/avc-fps-2.log", "-hw -b 10000 -f 30 -u 7 -priority 2 -async 4"],
);

our %msdk_sample_map = (
    ## test_type => linux, windows

    #"transcode" => ["sample_multi_transcode_drm", "sample_multi_transcode.exe"],
    #"encode"    => ["sample_encode_drm",          "sample_encode.exe"],
    #"decode"    => ["sample_decode_drm",          "sample_decode.exe"],
    #"vpp"       => ["sample_vpp_drm",             "sample_vpp.exe"],

    "transcode"  => ["sample_multi_transcode", "sample_multi_transcode.exe"],
    "encode"     => ["sample_encode",          "sample_encode.exe"],
    "decode"     => ["sample_decode",          "sample_decode.exe"],
    "vpp"        => ["sample_vpp",             "sample_vpp.exe"],
);


1;
