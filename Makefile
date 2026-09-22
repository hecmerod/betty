PIXEL6_SERIAL := 25141FDF6005UL
ADB_PORT := 5555

.PHONY: pixel6-wireless
pixel6-wireless:
	@ip=$$(adb -s $(PIXEL6_SERIAL) shell "ip -o -4 addr show" | awk '/wlan/ { split($$4, a, "/"); print a[1]; exit }'); \
	if [ -z "$$ip" ]; then \
		echo "Could not find Pixel 6 Wi-Fi address. Plug in USB and turn Wi-Fi on."; \
		exit 1; \
	fi; \
	adb -s $(PIXEL6_SERIAL) tcpip $(ADB_PORT); \
	adb connect $$ip:$(ADB_PORT)
