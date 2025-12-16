#!/usr/bin/env python3
"""
Test script to verify Neovim terminal mode Ctrl+Enter mapping.
This script will help you test if the \u001b[13;5u control character
is properly mapped to Ctrl+Enter in terminal mode.
"""

import sys
import time

def test_ctrl_enter():
    """Test function that responds to Ctrl+Enter input."""
    print("=== Neovim Terminal Ctrl+Enter Test ===")
    print("This script will test if Ctrl+Enter is properly received.")
    print("Press Ctrl+Enter to see if it's detected, or 'q' to quit.")
    print("=" * 50)
    
    try:
        import termios
        import tty
        
        # Save original terminal settings
        old_settings = termios.tcgetattr(sys.stdin)
        
        # Set terminal to raw mode
        tty.setraw(sys.stdin.fileno())
        
        while True:
            char = sys.stdin.read(1)
            
            if char == 'q':
                break
            elif char == '\r':  # Regular Enter
                print("\n[REGULAR ENTER DETECTED]")
            elif char == '\x0d':  # Ctrl+Enter (if properly mapped)
                print("\n[CTRL+ENTER DETECTED! ✓]")
            elif ord(char) == 13:  # Another way to detect Enter
                print(f"\n[ENTER DETECTED - ASCII: {ord(char)}]")
            else:
                # Print the character and its ASCII value for debugging
                print(f"\n[CHAR: {repr(char)} - ASCII: {ord(char)}]")
                
    except ImportError:
        print("termios not available on this system. Using fallback method.")
        print("Press Ctrl+Enter and watch for output...")
        
        while True:
            try:
                line = input()
                if line.lower() == 'q':
                    break
                print(f"Received: {repr(line)}")
            except KeyboardInterrupt:
                print("\n[INTERRUPT DETECTED]")
                break
            except EOFError:
                break
    
    finally:
        try:
            # Restore original terminal settings
            termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
        except:
            pass
    
    print("\nTest completed.")

if __name__ == "__main__":
    test_ctrl_enter()
