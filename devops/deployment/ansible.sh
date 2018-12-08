# Create Vault file
echo $ANSIBLE_VAULT_PASS > vault_pass_file

# Run the ansible playbook
if [ $DEPLOY_ENV = "blue" ]
then
  # Production deploy
  ansible-playbook -i "${ANSIBLE_INVENTORY}" "${ANSIBLE_PLAYBOOK}" --vault-password-file vault_pass_file --extra-vars "deploy_env=blue"
else
  # Beta deploy
  ansible-playbook -i "${ANSIBLE_INVENTORY}" "${ANSIBLE_PLAYBOOK}" --vault-password-file vault_pass_file --extra-vars "deploy_env=green"
fi

# Remove Vault file
rm -f vault_pass_file
