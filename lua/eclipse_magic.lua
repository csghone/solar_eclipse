-- Eclipse Magic
-- Programmed exposure sequence for a solar eclipse


-- Eclipse Magic
--
-- Version 1.5.0
--
-- Copyright 2017 by Brian Greenberg, grnbrg@grnbrg.org.
-- Distributed under the GNU General Public License.
--
--
-- ***************************************************************************************************
-- ***************************************************************************************************
--
-- **NOTE** At the current time, the "camera.burst()" functionality requires the "lua_fix"
-- beta build of Magic Lantern which can be found at https://builds.magiclantern.fm/experiments.html.
-- Hopefully this function will be merged into the mainline soon.
--
-- ***************************************************************************************************
-- ***************************************************************************************************
--
--
-- Read through the comments at the top of the script, and modify the contact points to suit
-- your location, and the exposure settings to suit your camera.  Copy the script to
-- the ML/SCRIPTS directory on your camera's media, and run it from the menu.
--
-- If you have issues, (and you aren't running with the test flag set) you should be able to
-- reboot your camera, and it will pick up where it left off.  Exposure events are tied to
-- particular times, not a sequence that needs to start at a specific time.  This is useful if
-- (for example) you need to change batteries in mid-eclipse.
--
-- See http://xjubier.free.fr/en/site_pages/SolarEclipseExposure.html for suggestions for
-- exposure values.
--
--
-- If this script is useful, feel free to send a PayPal donation to Eclipse-Magic@grnbrg.org,
-- or a Bitcoin donation to 1grnbrg3Ea4t6bxHvQKRvorbBeLNDXv2N.
--
-- ***************************************************************************************************
-- ***************************************************************************************************
-- ***************************************************************************************************

-- Modified by Chaitanya Ghone, csghone@gmail.com
-- 1. Whitespace cleaned-up
-- 2. Added a few functions

-- Variable definitons that have to go here.  Ignore them.
c1 = {}
c2 = {}
c3 = {}
c4 = {}


--
--  If you are testing, set this to 1, and the shutter won't be used.
--  Set it to 0 for the real event.
--
--  This changes how the contact times are interpreted!  If TestBeepNoShutter
--  is set to 1, then the contact times are time elapsed after the script is started.
--  it is set to 0, then the contact times reference the realtime clock of the camera.
--
--  For example:
--
--  If C1 is set to 10:30:00 (ie: 10:30:00 am), and the current time on the camera is set
--  to 08:00:00 (ie: 8:00:00 am), then
--
--  If TestBeepNoShutter is set to 1, then the script will start demonstrating eclipse exposures
--  in ten hours and thirty minutes.
--
--  If TestBeepNoShutter is set to 0, the script will start taking actual exposures in two
--  hours and thirty minutes (ie: at 10:30:00).
--
--  The intent was that (for testing) you could set C1 to 00:00:30 or so, and the other contacts to
--  similar offsets, and not worry about messing with the clock on the camera.  (This may not have
--  been the best choice on my part!  :) )
TestBeepNoShutter = 0
RunOnPC = 0
RunNow = 0

--
-- Set the 4 contact times here.  Time zone is irrelevant, as long as your camera and these
-- times are the same.  Make sure the times are correct for your location, and that your camera
-- is accurately set to GPS time.
--

-- https://eclipse2017.nasa.gov/sites/default/files/interactive_map/index.html (UTC)
c1.hr  = 16
c1.min = 6
c1.sec = 31

if (RunNow == 1)
then
    c1.hr  = 17
    c1.min = 18
    c1.sec = 0
end

c2.hr  = 17
c2.min = 19
c2.sec = 24

c3.hr  = 17
c3.min = 21
c3.sec = 18

c4.hr  = 18
c4.min = 40
c4.sec = 50

--
-- Set an aperture value.  The script assumes that the aperture stays constant throughout the
-- eclipe.  The camera will (try to) set this aperture (f-number) at the beginning of the script.
-- Useful, as it is easy to forget this, if you are shooting with a regular camera lens.
-- If the script and camera are being used with a fixed aperture lens (or telescope), then
-- set the "SetAperture" to 0.
SetAperture = 1
Aperture    = 5.0

--
-- If you shoot with LiveView active, you will reduce the amount of mirror slap, giving
-- less vibration.  But.  Some cameras (Such as the 5DmkII.) have a limited range of shutter
-- speed when LV and Movie mode are enabled.  This reduces the available speeds from 30 seconds
-- through 1/8000th of a second to 1/30th to 1/4000th of a second.  Exceeding that range while
-- LV and Movie mode are enabled will crash the script.
--
-- Setting this variable to 1 will, before taking any images, check if LV is running, and if it
-- is, will tell you to turn it off.  If you have disabled movie mode (A menu option on some cameras,
-- like the 5DmkII, and a hardware switch on others) you should set this to 0.
--
-- Test your camera.  If the exposure speeds you want crash the script in LV, check how to disable
-- movie mode.
--
WarnLiveView = 0


--
-- If you're shooting in Live View (to reduce mirror slap) you'll probably still want to check
-- your focus occasionally.  However, the status display of the script pretty much fills the screen,
-- making this difficult.  Enabling HideConsole will display the console for the indicated number
-- of seconds both before and after the next shutter event, and turn the console off between.  This
-- also gives you an idea of how much time you have before the next shutter event -- if the console
-- is hidden, you have at least ConsoleShowDelay seconds to mess around.  If you turn this off, the
-- script will start with the console displayed, and you will have to manage it through the Magic
-- Lantern menu.  If you turn it off, it stays off until you turn it on again.
--
HideConsole      = 1
ConsoleShowDelay = 30


--
-- Even if you shoot with Live View with Silent Mode 1 (which forces the mirror to be
-- locked up, and eliminates the vibration from the shutter opening) there will be slight
-- vibrations introduced as the shutter closes.  According to Jerry Lodriguss at
-- http://www.astropix.com/wp/2017/07/17/mirror-slap-and-shutter-shock/ these vibrations
-- are most prominent between 0.125s and 2s, and can be somewhat mitigated by a slight
-- delay before exposure, to allow the vibration to dampen a bit.
--
-- Enabling this option lets you set a range of shutter speeds to delay before, and
-- how long (in milliseconds) to pause.
--
DoShutterShockDelay   = 1
SlowestDelayedShutter = 2
FastestDelayedShutter = (1/8)
ShutterShockDelayMS   = 300        -- Value is in milliseconds!


--
-- Partial phase settings.
--
PartialISO           = 100
PartialShutterSpeed  = (1/2000)
PartialMarginTime    = 15 -- Number of seconds after C1 or C3 and before C2 or C4 to start exposures
PartialExposureCount = 4  -- Number of partial phase exposures before and after totality
PartialDoBkt         = 1  -- Do you want to do exposure bracketing?  1 - yes, 0 - no
PartialBktStep       = 1  -- Number of f-stops in each step.  Can 0.333333, 1, 2, etc
PartialBktCount      = 1  -- How many brackets on each side of the neutral exposure?


--
-- Do a fast burst of exposures at C2 and C3, to try to get Baily's beads and chromosphere.
-- You will need to know how many exposures your camera will buffer, and how long it takes the
-- buffer to fill.  At "StartOffset" seconds before C2 or C3, the camera will take "BurstCount"
-- exposures, as fast as it can.  You should adjust C23StartOffset so that burst of image straddles
-- the contact time.  Note that, between the setting of the camera clock and the jitter in this
-- script, there will be some error in the timing.  +/- half a second or more is possible.
--
C23BurstCount        = 14 -- Note that most Canon DSLRs can't take more than 13-14 RAW images
                          -- in a burst before the buffer is full, and they slow to ~1 image/second.
C2BurstStartOffset   = 3
C3BurstStartOffset   = 2
C23BurstISO          = 100
C23BurstShutterSpeed = (1/500)


--
-- During the time between C2 and C3, the script will run back and forth between the
-- "MinShutterSpeed" and "MaxShutterSpeed" as quickly as possible, with an extra 2 long exposures
-- at midpoint.  "ExpStep" is the size of the f-stop variation, and can be set to 0.333333, 1, 2, etc.
-- Min, Max and PrefISO:  Totality exposures will run (where possible) at PrefISO.  However, there
-- will also be exposures at MinShutterSpeed from MinISO to PrefISO, and MaxShutterSpeed from
-- PrefISO to MaxISO.
--
TotalityMinISO          = 100
TotalityMaxISO          = 1600
TotalityPrefISO         = 400
TotalityMinShutterSpeed = (1/8000) -- (MinShutterSpeed is the *fastest* speed to use.)
TotalityMaxShutterSpeed = 1.0      -- 1 sec (MaxShutterSpeed is the *slowest*, longest speed used.)
TotalityExpStep         = 1

--
-- One of the more difficult exposures to capture is earthshine -- the surface of the moon,
-- illuminated by light reflected from the earth.
--
-- The best time to do this is at the point of maximum eclipse, where the sun is centred behind
-- the moon, as much as possible.  Exposures here are kind of guesswork, and I have actually turned this
-- off by default.
--
DoMaxExposures = 1     -- Number of (possibly bracketed) exposures to take at max-eclipse.
MaxOffset      = (7/2) -- How long before max eclipse to start these exposures.  You'll have to test
                       -- or use math to determine this value.  (Value is in seconds.)
NumMaxExposures = 1
DoMaxBrackets   = 1    -- Brackets?
NumMaxBrackets  = 1
MaxBracketStep  = 1
MaxISO          = 3200
MaxShutterSpeed = 2.0


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--
--                                       HERE THERE BE DRAGONS
--
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


--
-- Times are easiest to deal with in seconds.  This would be painful if they crossed over midnight,
-- but late-night solar eclipses are rare.
--
c1_sec = c1.hr * 3600 + c1.min * 60 + c1.sec
c2_sec = c2.hr * 3600 + c2.min * 60 + c2.sec
c3_sec = c3.hr * 3600 + c3.min * 60 + c3.sec
c4_sec = c4.hr * 3600 + c4.min * 60 + c4.sec
max_sec = c2_sec + ((c3_sec - c2_sec) / 2)

MaxOffset = MaxOffset * DoMaxExposures -- This is ugly, and shouldn't be here.

tick_offset   = 0
TestStartTime = 0

if (RunOnPC == 1)
then
else
    os = {}
end

if (RunOnPC == 1)
then
    clock_rate = os.clock()
    start = os.time()
    while (os.time() < start + 5) do
    end
    clock_rate = (os.clock() - clock_rate)/5000.0
    menu = {}
    function menu.close()
    end
    console = {}
    function console.show()
    end
    function console.hide()
    end
    event = {}
    task = {}
    camera = {}
    function camera.burst()
    end
    MODE = {}
    MODE.M = 1
    camera.mode = MODE.M
    camera.iso = {}
    camera.iso.value = 100
    camera.shutter = {}
    camera.shutter.value = 1
    camera.shutter.ms = 1
    camera.aperture = {}
    lv = {}
    function msleep(val)
        local end_val = os.clock() + clock_rate*val
        while (os.clock() < end_val) do
        end
    end
    function beep()
    end
    function task.yield(val)
        msleep(val)
    end
end


--
-- Get the current time (in seconds) from the camera's clock.
--
function get_cur_secs ()
    local cur_time
    if (RunOnPC == 1)
    then
        cur_time = os.date("*t")
    else
        cur_time = dryos.date
    end
    local cur_secs = (cur_time.hour * 3600 + cur_time.min * 60 + cur_time.sec)
    --if ( TestBeepNoShutter == 1 )
    --then
        --cur_secs = (cur_secs - TestStartTime) -- If we're testing, start the clock at
                                              ---- now, not actual time.
    --end
    return cur_secs
end


--
-- Custom shutter-info printer function
--
function print_shutter_info(id)
    print(id, "Time:", pretty_time(get_cur_secs()), "ISO:", camera.iso.value,
          "shutter: 1/", 1/camera.shutter.value)
end

--
-- Take a time variable expressed in seconds (which is what all times are
-- stored as) and convert it back to HH:MM:SS
--
function pretty_time (time_secs)
    local text_time = ""
    local hrs = 0
    local mins = 0
    local secs = 0

    hrs  = math.floor(time_secs / 3600)
    mins = math.floor((time_secs - (hrs * 3600)) / 60)
    secs = (time_secs - (hrs*3600) - (mins * 60))

    text_time = string.format("%02d:%02d:%02d", hrs, mins, secs)

    return text_time
end

--
-- LIVEVIEW WARNING
--
function warn_live_view()
    if ((lv.enabled == true) and (WarnLiveView == 1))
    then
        print ("TURN LIVEVIEW OFF (OR DISABLE MOVIE MODE) AND PRESS A BUTTON!!!")
        do_beep()
        key.wait()
    end
end


--
-- Hurry up and wait for the next important time to arrive.
--
-- Leave the console displayed for 60 seconds at the start and end of
-- a wait.  Turn it off between, so that tracking can be done via live view, etc.
--
function wait_until (done_waiting)
    local counter = get_cur_secs()
    local next_sec = 0
    local show_console = ConsoleShowDelay
    local console_visible = 1

    console.show()
    print ("Current time", pretty_time(counter))
    print ("Waiting for", pretty_time(done_waiting), "in",
           string.gsub(string.format("%7d",(done_waiting - counter)), " ", ""), "seconds.")

    repeat
        task.yield (1000) -- Let the camera do other tasks for a second.

        if ((HideConsole == 1) and (show_console > 0))
        then
            show_console = show_console -1
        elseif ((HideConsole == 1) and (show_console == 0))
        then
            console.hide()
            show_console = -1
            console_visible = 0
        end

        if ((HideConsole == 1) and ((done_waiting - counter) < 30 ) and (console_visible == 0))
        then
            console.show()
            console_visible = 1
        end

        counter = get_cur_secs()
    until (counter >= (done_waiting - 1))

    -- Loop /should/ exit the second before we are done. But
    --  It's possible that it could exit early in our target
    --  second. If so, we don't want to wait around to
    --  (done_waiting + 1) to exit.
    if ( counter < done_waiting)
    then
        if (RunOnPC == 1)
        then
            next_sec = 1000
        else
            next_sec = (1000 - ((dryos.ms_clock - tick_offset) % 1000))
        end
        msleep (next_sec) -- Hard sleep, don't let anything else have priority.
    end
end

--
-- Shoot if not in test mode
--
function shoot_or_beep()
    if (TestBeepNoShutter == 0)
    then
        camera.shoot(false)
        task.yield(10) -- Exposures can take time.  Give other stuff a chance to run.
    else
        beep(1,50)
        task.yield (600 + camera.shutter.ms)
    end
end


--
-- Say "CHEESE!".  Set up the camera, and take a picture.  Also deals with any requested
-- bracketing.
--
function take_shot(iso, shutter_speed, dobkt, bktstep, bktcount)
    local bktspeed = 0.0

    warn_live_view()

    camera.iso.value = iso
    if (dobkt == 0)
    then    -- Single exposure
        camera.shutter.value = shutter_speed
        print_shutter_info("Click!")

        if (DoShutterShockDelay == 1)
        then
            if ((shutter_speed > FastestDelayedShutter) and (shutter_speed
                < SlowestDelayedShutter))
            then
                task.yield(ShutterShockDelayMS)
            end
        end

        shoot_or_beep()
    else    -- Bracketing exposure
        -- Loop through the requested number of exposure brackets.
        for bktnum = bktcount,(-1 * bktcount),-1 do
            bktspeed             = shutter_speed * (2.0^(bktnum * bktstep))
            camera.shutter.value = bktspeed
            print_shutter_info("Click!")

            if (DoShutterShockDelay == 1)
            then
                if ((shutter_speed > FastestDelayedShutter) and (shutter_speed
                    < SlowestDelayedShutter))
                then
                    task.yield(ShutterShockDelayMS)
                end
            end

            shoot_or_beep()
        end
    end
end


--
-- Burst is simpler than single shot, because no brackets.  Set the camera, pull the trigger.
--
-- I have tried replacing this with multiple calls to "camera.shoot()", but it is still considerably
-- slower than "camera.burst()", and can also crash the camera -- nothing permanent, but still
-- not something I want to put out.
--
function take_burst (count, iso, speed)
    camera.shutter.value = speed
    camera.iso.value = iso

    warn_live_view()

    print_shutter_info("Burst!")

    if (TestBeepNoShutter == 0)
    then
        camera.burst(count)
        task.yield(10)
    else
        beep(3,50)
        task.yield (4000 + (count * camera.shutter.ms))
    end
end


--
-- Simple annoying camera beep.
--
function do_beep()
    beep (5,100)
    task.yield (250)
    beep (5,100)
    task.yield (250)
    beep (5,100)
end


--
-- Take the spaced exposures for the C1-C2 and C3-C4 periods.  Take the margin times off either
-- end, split the time into the right intervals, and fire off take_picture()
--
function do_partial (start_phase, stop_phase, which_partial)
    local image_time = 0
    local image_interval = math.floor((stop_phase - start_phase) / (PartialExposureCount))
    local exposure_count = 0

    -- In a series of (PartialCount + 1) images, totality is either
    --    the first or last image.  This arranges the timing so that there
    --    will be a equidistance set of ((2 x PartialCount) + 1) exposures,
    --    with totality properly centered.

    if (which_partial == "Pre")
    then
        image_time = start_phase
    else
        image_time = start_phase + image_interval
    end

    if ( get_cur_secs() >= stop_phase ) -- Are we past this phase already?
    then
        return
    end

    repeat
        if (get_cur_secs() <= image_time)
        then
            wait_until(image_time)
            take_shot (PartialISO, PartialShutterSpeed, PartialDoBkt, PartialBktStep, PartialBktCount)
        end
        image_time = image_time + image_interval
        exposure_count = exposure_count + 1
    until (exposure_count >= PartialExposureCount)

end


--
-- Start the burst shot a little before C2, then start running through exposure settings, going from
-- short, fast exposures to slow, long exposures and thenback to short, until just before the midpoint
-- of the eclipse.  <strikethrough>Take two long exposures at that point, for good measure.</strikethrough>
--
function do_c2max()
    local cur_shutter_speed = 0
    local CurISO = 0

    if ( get_cur_secs() >= max_sec ) -- Are we past this phase already?
    then
        return
    end

    if ( get_cur_secs() <= (c2_sec - C2BurstStartOffset) ) -- Have we past the burst for Baily's beads?
    then
        wait_until (c2_sec - (C2BurstStartOffset + 30))

        print()
        print("********************************************************")
        print("30 seconds to C2!  Remove Filter!")
        print("********************************************************")
        print()
        do_beep()
        wait_until (c2_sec - C2BurstStartOffset)
        take_burst (C23BurstCount, C23BurstISO, C23BurstShutterSpeed)

        print()
        print("********************************************************")
        print("Post C2 warning!")
        print("********************************************************")
        print()
        do_beep()
    end

    cur_shutter_speed = TotalityMinShutterSpeed
    CurISO            = TotalityMinISO

    repeat
        take_shot(CurISO, cur_shutter_speed, 0, 0, 0)
        if (CurISO < (TotalityPrefISO * 0.95))
        then
            CurISO = CurISO * 2.0^TotalityExpStep
        elseif ((CurISO < (TotalityPrefISO * 1.1)) and
                (cur_shutter_speed < (TotalityMaxShutterSpeed * 0.95)))
        then
            cur_shutter_speed = cur_shutter_speed * 2.0^TotalityExpStep
        elseif (CurISO < (TotalityMaxISO * 0.95))
        then
            CurISO = CurISO * 2.0^TotalityExpStep
        else
            cur_shutter_speed = TotalityMinShutterSpeed
            CurISO = TotalityMinISO
        end
    until (get_cur_secs() >= (max_sec - MaxOffset)) -- Stop, and leave time to do the mid-eclipse earthshine
                                                    -- exposures.
end


--
-- do_max -- Take a number of long exposures at the time of maximum eclipse, to try to capture
-- an earthshine image.  These can be bracketed.
--
function do_max()
    if (DoMaxExposures == 0)  -- Are we doing this?
    then
        return    -- Nope.
    end

    for count_max_exp = NumMaxExposures , 1 , -1 do
        take_shot(MaxISO, MaxShutterSpeed, DoMaxBrackets, NumMaxBrackets, MaxBracketStep)
    end
end


--
-- Similar to do_c2max, but reversed.  Exposures run from longest to shortest (and then repeat),
-- the burst starts just before C3, and there are no bonus exposures.
--
function do_maxc3()
    local cur_shutter_speed = 0
    local CurISO = 0

    if ( get_cur_secs() >= (c3_sec + C3BurstStartOffset) ) -- Are we past this phase already?
    then
        return
    elseif ( get_cur_secs() < (c3_sec - C3BurstStartOffset) ) -- Do we have time for some totality exposures?
    then
        cur_shutter_speed = TotalityMaxShutterSpeed
        CurISO = TotalityMaxISO

        repeat
            take_shot(CurISO, cur_shutter_speed, 0, 0, 0)
            if (CurISO > (TotalityPrefISO * 1.05))
            then
                CurISO = CurISO / 2.0^TotalityExpStep
            elseif ((CurISO > (TotalityPrefISO * 0.95)) and
                    (cur_shutter_speed > (TotalityMinShutterSpeed * 1.05)))
            then
                cur_shutter_speed = cur_shutter_speed / 2.0^TotalityExpStep
            elseif (CurISO > (TotalityMinISO * 1.01))
            then
                CurISO = CurISO / 2.0^TotalityExpStep
            else
                cur_shutter_speed = TotalityMaxShutterSpeed
                CurISO = TotalityMaxISO
            end

        until (get_cur_secs() >= (c3_sec - (C3BurstStartOffset + 3)))

        print()
        print("********************************************************")
        print("3 seconds to C3!  Filter warning!")
        print("********************************************************")
        print()

        do_beep()

    end

    wait_until (c3_sec - C3BurstStartOffset)

    take_burst (C23BurstCount, C23BurstISO, C23BurstShutterSpeed)

    print()
    print("********************************************************")
    print("End of totality! Replace filter!")
    print("********************************************************")
    print()

    do_beep()

end

--
-- The ringleader.
--
function main()
    local starttime
    local offset = 0
    local offset_count = 0

    starttime = get_cur_secs()

    TestStartTime = starttime
    print("starttime", starttime)

    menu.close()
    console.show()

    local temp = c1_sec

    if (RunNow == 1)
    then
        c1_sec = c1_sec + TestStartTime
        c2_sec = c2_sec + TestStartTime
        c3_sec = c3_sec + TestStartTime
        c4_sec = c4_sec + TestStartTime

        c1_sec = c1_sec - temp
        c2_sec = c2_sec - temp
        c3_sec = c3_sec - temp
        c4_sec = c4_sec - temp

        max_sec = c2_sec + ((c3_sec - c2_sec) / 2)
    end

    print ()
    print ()
    print ("-------------------------------------")
    print ("  Eclipse Magic")
    print ("  Copyright 2017, grnbrg@grnbrg.org")
    print ("  Released under the GNU GPL")
    print ("-------------------------------------")
    print ()
    print ("Starting 10 second timing calibration....")


    --------------------------------------------------------------------------
    offset = 0
    offset_count = 0
    --
    -- The camera maintains a millisecond timer since power-on.  We can use this to
    -- get close to the beginning of a given second.  I think.
    --
    event.seconds_clock = function (ignore)
        offset       = offset + (dryos.ms_clock - (1000 * offset_count))
        offset_count = offset_count + 1
        return true
    end

    --
    -- There is a fair amount of jitter in the event timer.  Averaging over 10 seconds will
    -- give us a reasonable offset.
    -- Seems to be stable even if 1000 is used - CSG
    --
    task.yield(1500)

    -- Turn off the second_clock event timer.
    event.seconds_clock = nil

    tick_offset = (math.floor(offset / offset_count) % 1000)
    print("tick_offset", tick_offset, offset, offset_count)
    --------------------------------------------------------------------------


    print ("Done!")
    print ()

    print("Current:", pretty_time(get_cur_secs()))
    print("C1     :", pretty_time(c1_sec))
    print("C2     :", pretty_time(c2_sec))
    print("MAX    :", pretty_time(max_sec))
    print("C3     :", pretty_time(c3_sec))
    print("C4     :", pretty_time(c4_sec))

    -- If the camera is not in manual mode, trying to set the shutter speed throws errors.
    -- Check to make sure we are in manual mode, and refuse to run if we're not.
    if (camera.mode == MODE.M)
    then
        if (SetAperture == 1)
        then
            camera.aperture.value = Aperture
        end

        do_partial ((c1_sec + PartialMarginTime), c2_sec, "Pre")
        do_c2max()
        do_max()
        do_maxc3()
        do_partial (c3_sec, (c4_sec - PartialMarginTime), "Post")
    else
        beep (5, 100)
        print("Camera must be in manual (M) mode!!")
        print()
        print("Press any button to exit the script.  Change the mode and re-run.")
        key.wait()
    end

    console.hide()
end -- Done.  Hope there were no clouds.


main() -- Run the program.

-- CHANGES

-- 1.0.1
    -- Stopped running the seconds_clock event at all times, and moved the tick_offset
        -- calculation to the setup at the start of execution
    -- Fixed the pretty-printing of the timer
    -- Fixed the sign of the C23BurstStartOffset in do_maxc3
    -- Fixed the calculation of the difference between current time and the next second
        -- in wait_until()
    -- Added code to turn off the console during long waits
    -- Massaged the end-of-exposure-bracketing conditions in do_c2max() and do_maxc3()

-- 1.1
    -- Changed the partial phase exposure logic, so that instead of there being an exposure
        -- at C1 and C2, there is an exposure at C1 and an exposure at (C2 - exposure_interval)
        -- so that the totality images are properly centered between the requested partial phase
        -- exposures.
    -- Added an alarm at 30 seconds before C2 and 3 seconds before C3 to alert for any filter changes.
        -- There is also a beep after the C2 and C3 bursts to flag any needed changes.
    -- Split the C23BurstStartOffset into separate variables, to allow an asymmetric burst over
        -- each period.  (ie: 10 seconds before C2 to 3 seconds after C2)

-- 1.2
    -- Added ISO brackets to totality exposure sequence.  Totality now has a preferred ISO,
        -- and will shift to that ISO at the fastest or slowest shutter speeds, then use that
        -- preferred ISO for the requested range of shutter speeds, then shift ISO to the end of
        -- the requested range.
    -- Option to stop LiveView before touching the shutter controls.
    -- Removed the two long exposures at max eclipse -- probably not needed.

-- 1.2.1
    -- Changed call to lv.stop() to a beep, and instruction to the user to turn off LV.
        -- lv.stop() doesn't seem to work.
    -- Added print statements to explain filter warning beeps.

-- 1.3.0
    -- Changed the startup timing loop to be more accurate if the script is started close to
        -- a second boundary.  (The average offset of 999ms and 1ms is 1ms, not 500ms)
    -- Corrected an error in wait_until() -- Used div, where modulus was correct, and had
        -- the tick_offset correction wrong.  Don't code while tired.  Thanks to
        -- matman730 for pointing out this goof.
    -- Improved the configuration comments around TestBeepNoShutter.  They apparently weren't
        -- clear as I thought.

-- 1.4.0  (Not released)
        -- Attempt to implment the changing of the file prefix for the saved images.  It didn'take
            -- work well, and I scrapped it.

-- 1.5.0
    -- Make it optional to hide the console during script running, and allow the delay before
        -- and after the next image to be configured.
    -- Shutter shock reduction:  Add a configurable (in milliseconds) delay before an exposure
        -- where the shutter speed is within a (also configurable) range.
    -- Add a mid-eclipse section.  This is a short section around the max eclipse point to optionally
        -- try for some earthshine exposures.
    -- Set the aperture on program start.
