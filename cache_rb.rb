$web = 1
$run = 1
$totalrun = 11
$ip3 = 70
$ip4 = 37
weblist = []

while $web <= 10 do

	webname = weblist[web-1]

	system("adb shell rm /sdcard/test.txt")
	system("adb shell rm /sdcard/web*")
	system("adb logcat -c")

	Thread.new{
		system("adb logcat -f /sdcard/test.txt")
	}

	start_test_server_in_background
	sleep(5)
	btn=query("edittext")
	touch(btn)
	keyboard_enter_text "http://130.245.#$ip3.#$ip4/new/"+webname

	Thread.new{
		system("PowerToolCmd.exe /TRIGGER=ATYD200A /SAVEFILE=temp.pt4 /capturedatamask=0x1222 /VOUT=4.00 /USB=ON /ISTART /noexitwait /keeppower")
		system("rename temp.pt4 websites#$web.pt4")
		system("rename temp.csv websites#$web.csv")

	}
	sleep(10)

	while $run <= $totalrun  do
		
		system("adb shell input tap 660 1120")
		sleep(15)

		system("adb shell cp /sdcard/test.txt /sdcard/websites#$web.txt")
		system("adb shell rm /sdcard/test.txt")

		btn = query("edittext")
		if btn.empty?
			system("adb shell input tap 590 670")
		end
	  	$run += 1
	end

	reinstall_apps
	$web += 1
end
