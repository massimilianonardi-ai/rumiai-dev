# `@package` schema v0 — reference descriptor stress cases

Data: 2026-08-30

Stato: **architectural schema stress test — System Field Format v0**

Gli esempi mostrano soltanto le sezioni rilevanti; identity/release/integrity metadata seguono lo schema v0.

---

# 1. Temurin 21 provider

```text
interface_directory_count	2
interface_directory_1_id	home
interface_directory_1_path	.
interface_directory_2_id	bin
interface_directory_2_path	bin

interface_file_count	2
interface_file_1_id	java-exe
interface_file_1_path	bin/java
interface_file_2_id	javac-exe
interface_file_2_path	bin/javac

interface_command_count	2
interface_command_1_id	java
interface_command_1_executable_source	self
interface_command_1_executable_resource_type	file
interface_command_1_executable_resource	java-exe
interface_command_1_arg_count	0
interface_command_2_id	javac
interface_command_2_executable_source	self
interface_command_2_executable_resource_type	file
interface_command_2_executable_resource	javac-exe
interface_command_2_arg_count	0

interface_provide_count	2
interface_provide_1_capability	java-runtime
interface_provide_1_contract	1
interface_provide_1_version	21
interface_provide_1_resource_count	3
interface_provide_1_resource_1_key	command
interface_provide_1_resource_1_resource_type	command
interface_provide_1_resource_1_resource	java
interface_provide_1_resource_2_key	home
interface_provide_1_resource_2_resource_type	directory
interface_provide_1_resource_2_resource	home
interface_provide_1_resource_3_key	bin
interface_provide_1_resource_3_resource_type	directory
interface_provide_1_resource_3_resource	bin

interface_provide_2_capability	java-development-kit
interface_provide_2_contract	1
interface_provide_2_version	21
interface_provide_2_resource_count	4
interface_provide_2_resource_1_key	java
interface_provide_2_resource_1_resource_type	command
interface_provide_2_resource_1_resource	java
interface_provide_2_resource_2_key	javac
interface_provide_2_resource_2_resource_type	command
interface_provide_2_resource_2_resource	javac
interface_provide_2_resource_3_key	home
interface_provide_2_resource_3_resource_type	directory
interface_provide_2_resource_3_resource	home
interface_provide_2_resource_4_key	bin
interface_provide_2_resource_4_resource_type	directory
interface_provide_2_resource_4_resource	bin
```

Provider identity resta native, per esempio:

```text
temurin@21.0.8+9@r1@linux-arm64
```

PASS.

---

# 2. NetBeans consumer `any-any`

Normalized writable islands:

```text
root/etc      -> ../run/etc
root/userdir  -> ../run/userdir
root/cache    -> ../run/cache
root/log      -> ../run/log
```

```text
state_present	true
state_compatibility_version	1
state_scope	shared
state_mapping_count	4
state_mapping_1_path	etc
state_mapping_1_area	conf
state_mapping_2_path	userdir
state_mapping_2_area	home
state_mapping_3_path	cache
state_mapping_3_area	cache
state_mapping_4_path	log
state_mapping_4_area	log

interface_file_count	1
interface_file_1_id	launcher
interface_file_1_path	bin/netbeans
interface_directory_count	0
interface_command_count	1
interface_command_1_id	netbeans
interface_command_1_executable_source	self
interface_command_1_executable_resource_type	file
interface_command_1_executable_resource	launcher
interface_command_1_arg_count	0
interface_provide_count	0

requirement_count	1
requirement_1_slot	jdk
requirement_1_target	capability
requirement_1_capability	java-development-kit
requirement_1_contract	1
requirement_1_constraint	>=17 <22

environment_count	2
environment_1_name	JAVA_HOME
environment_1_operation	set
environment_1_type	path
environment_1_value_source	dependency
environment_1_value_slot	jdk
environment_1_value_resource_type	directory
environment_1_value_resource	home
environment_2_name	PATH
environment_2_operation	prepend
environment_2_type	path-list
environment_2_value_source	dependency
environment_2_value_slot	jdk
environment_2_value_resource_type	directory
environment_2_value_resource	bin
```

Possible resolution:

```text
netbeans@26@r1@any-any
└── jdk -> temurin@21.0.8+9@r1@linux-arm64
```

PASS.

---

# 3. Python runtime provider

```text
interface_directory_count	2
interface_directory_1_id	home
interface_directory_1_path	.
interface_directory_2_id	bin
interface_directory_2_path	bin
interface_file_count	1
interface_file_1_id	python-exe
interface_file_1_path	bin/python3
interface_command_count	1
interface_command_1_id	python
interface_command_1_executable_source	self
interface_command_1_executable_resource_type	file
interface_command_1_executable_resource	python-exe
interface_command_1_arg_count	0
interface_provide_count	1
interface_provide_1_capability	python-runtime
interface_provide_1_contract	1
interface_provide_1_version	3.12
interface_provide_1_resource_count	3
interface_provide_1_resource_1_key	command
interface_provide_1_resource_1_resource_type	command
interface_provide_1_resource_1_resource	python
interface_provide_1_resource_2_key	home
interface_provide_1_resource_2_resource_type	directory
interface_provide_1_resource_2_resource	home
interface_provide_1_resource_3_key	bin
interface_provide_1_resource_3_resource_type	directory
interface_provide_1_resource_3_resource	bin
```

Provider è native, per esempio `cpython@...@linux-arm64`.

PASS.

---

# 4. Python hosted application `any-any`

```text
interface_file_count	1
interface_file_1_id	main-script
interface_file_1_path	app/main.py
interface_directory_count	0
interface_command_count	1
interface_command_1_id	example-app
interface_command_1_executable_source	dependency
interface_command_1_executable_slot	python
interface_command_1_executable_resource_type	command
interface_command_1_executable_resource	python
interface_command_1_arg_count	1
interface_command_1_arg_1_source	self
interface_command_1_arg_1_resource_type	file
interface_command_1_arg_1_resource	main-script
interface_provide_count	0
requirement_count	1
requirement_1_slot	python
requirement_1_target	capability
requirement_1_capability	python-runtime
requirement_1_contract	1
requirement_1_constraint	=3.12
environment_count	0
```

PASS.

---

# 5. Pulsar Electron/self-contained

```text
interface_file_count	1
interface_file_1_id	pulsar-exe
interface_file_1_path	bin/pulsar
interface_directory_count	0
interface_command_count	1
interface_command_1_id	pulsar
interface_command_1_executable_source	self
interface_command_1_executable_resource_type	file
interface_command_1_executable_resource	pulsar-exe
interface_command_1_arg_count	0
interface_provide_count	0
requirement_count	0
environment_count	0
```

Nessun requirement artificiale Java.

PASS.

---

# 6. Integrity metadata + inventory

Descriptor:

```text
integrity_method	1
integrity_algorithm	sha256
integrity_root_inventory	@integrity-root.tsv
integrity_root_files	2
integrity_root_directories	2
integrity_root_links	1
integrity_root_manifest_digest	...
integrity_run_default_inventory	@integrity-run-default.tsv
integrity_run_default_files	0
integrity_run_default_directories	1
integrity_run_default_links	0
integrity_run_default_manifest_digest	...
```

`@integrity-root.tsv`:

```text
kind	integrity
schema	1
directory_count	2
directory_1_path	.
directory_1_mode	0500
directory_2_path	./bin
directory_2_mode	0500
file_count	2
file_1_path	./app.jar
file_1_mode	0400
file_1_digest	<digest>
file_2_path	./bin/foo
file_2_mode	0500
file_2_digest	<digest>
link_count	1
link_1_path	./log
link_1_target	../run/log
link_1_digest	<digest-target>
```

PASS.

---

# 7. Conclusion

Il modello a due campi copre senza nuove primitive:

```text
native runtime provider
any-any Java/Python consumer
private runtime resolution
state routing
environment isolation
hosted/direct commands
capability contracts
self-contained app
integrity inventory nello stesso System Field Format
nested collections con count + indici
```

Result:

```text
PASS
```
