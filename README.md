# Ansible Playbook Testing with Molecule

Focused on API-based testing (rather than OS provisioning testing), this project serves as a showcase of how molecule can be leveraged for playbook testing. It builds upon the concepts discussed here by Jeff Geerling: https://www.youtube.com/watch?v=CYghlf-6Opc

## Driver - Delegated

The molecule.yml is configured with the driver in accordance with [this code block](https://github.com/ansible-community/molecule/blob/54518f9bb1e70e527eee135be9d96b29a88f37c2/src/molecule/driver/delegated.py#L126)

i.e.

```
        driver:
          name: delegated
          options:
            managed: False
            ansible_connection_options:
              ansible_connection: local
```

## Where to run "test" set up in the molecule lifecycle

We need molecule to

1. Run set up to configure the target API ready such that the target infrastructure has its pre-conditions set up (e.g. Ansible playbooks for auto-merging PRs on GitHub via its API would require a test set up step to create the PR)
2. Pass any dynamically created vars to the playbook test step (e.g. the PR number that the set up step created)

Typically, set_facts will be covering this kind of use case as described here: https://techsemicolon.github.io/blog/2019/07/07/ansible-everything-you-need-to-know-about-set-facts/

Especially...

Caching a set fact :
You can cache a fact set from set_facts module so that when you execute your playbook next time, it's retrieved from cache. You can set cacheable to yes to store variables across your playbook executions using a fact cache. You may need to look into precedence strategies used by ansible to evaluate the cacheable facts mentioned in their [documentation](https://docs.ansible.com/ansible/latest/modules/set_fact_module.html?highlight=set_facts).

According to Molecule docs

```
Reserve the create and destroy playbooks for provisioning. Do not attempt to gather facts or perform operations on the provisioned nodes inside these playbooks. Due to the gymnastics necessary to sync state between Ansible and Molecule, it is best to perform these tasks in the prepare or converge playbooks.

It is the developers responsibility to properly map the modules’ fact data into the instance_conf_dict fact in the create playbook. This allows Molecule to properly configure Ansible inventory.
```

Note that in our case we use delegated and using "create" and "destroy" results in 

```
WARNING  Skipping, instances are delegated
```

We therefore need to use "prepare" and "cleanup"

### Using Prepare

Prepare does not run on ever occurrence of converge only the first. If you wish to always run prepare you can run molecule destroy first or molecule prepare --force state is kept in the state file in $TMPDIR/molecule/. From [here](https://github.com/ansible-community/molecule/issues/1459#issuecomment-417517372)

## Appendix

### Custom Drivers

It could be an option to implement a custom driver to facilitate testing of a core API i.e. if you are always working against iDRAC apis

An example custom driver is here: https://github.com/ansible-community/molecule-digitalocean/blob/master/molecule_digitalocean/driver.py