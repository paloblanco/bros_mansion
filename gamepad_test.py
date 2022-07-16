import vgamepad as vg
import time


if __name__ == "__main__":
    players=[]
    for i in range(8):
        players.append(vg.VX360Gamepad())
        print(f"Plugged in player {i}")
        time.sleep(3.0)    
    print("All players in, waiting 7 seconds")
    time.sleep(7.0)

    while True:
        for gamepad in players:
            gamepad.press_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_A)  # press the A button
            gamepad.update()  # send the updated state to the computer
        print("players pushed a")
        time.sleep(1.0)
        for gamepad in players:
            gamepad.release_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_A)  # press the A button
            gamepad.update()  # send the updated state to the computer
        print("players released a")
        time.sleep(1.0)