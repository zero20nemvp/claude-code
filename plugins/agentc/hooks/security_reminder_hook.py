#!/usr/bin/env python3
# Wrapper for locked security_reminder_hook - delegates to run script
import subprocess, sys, os
script_dir = os.path.dirname(os.path.abspath(__file__))
run_script = os.path.join(script_dir, '..', 'run')
locked_file = os.path.join(script_dir, 'security_reminder_hook.py.locked')
result = subprocess.run([run_script, locked_file] + sys.argv[1:])
sys.exit(result.returncode)
