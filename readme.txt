Performace test for Intel MSDK sample

1. setup sample_multi_transcode_drm
    $ ln -sf <dir>/sample_multi_transcode <$PWD>/binary

2. setup stream 
    $ ln -sf <dir>/<file-name>.h264  <$PWD>/stream/1080p.h264
    $ ln -sf <dir>/<file-name>.m2t   <$PWD>/stream/1080p.m2t

3. run test
    $ ./run.sh

4. custom your test
    $ vim lib/config.pm

    ## modify %test_map for your test
    ## modify $sample_bin_path for your folder of sample_multi_transcode
    ## modify &create_range_map function for loop test

5. show fps
    $ tail -F -q output/*.log 2>/dev/null
