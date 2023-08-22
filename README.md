Usage:
- Define AWS SSO Profiles in the ~/.aws/config file using this format: 
```bash
[profile <user>_<project>_<environment>]
sso_start_url=<your_sso_url>
sso_region=<your_sso_region>
sso_account_id=<your_account_id>
sso_role_name=<your_sso_role_name>
region=<your_profile_region>
output=json
```
- Rename ```aws/aws_config.sh.sample``` as ```aws/aws_config.sh```
- Rename ```aws/aws_commands.sh.sample``` as ```aws/aws_commands.sh```
- Set :
  - ```users```, 
  - ```projects```, 
  - ```environments``` 
  - and ```default_command``` in ```aws/aws_config.sh``` (the ```default_command``` if the name of a function defined in the  ```aws/aws_commands.sh``` file)
  - Set the tool as executable, eg:  ```chmod +x aws/aws_tool.sh```
  - Execute the tool, eg: ```./aws/aws_tool.sh```, then choose a function to execute. You must be "sso-logged" on AWS either before using the tool either using the ```command_aws_sso``` function (defined in the default command file)
  - Add your own commands in the ```aws/aws_commands.sh``` file

If the ```AWS_PROFILE``` is defined as ```<user>_<project>_<environment>``` then user, project and environment are automatically defined. If not, you'll be asked for a user, a project and an environment (as per the definitions in the ```aws/aws_config.sh``` file).

```CTRL+C``` to quit the tool without choosing a function.
