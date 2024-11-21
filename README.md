## Tutorial Buildroot utilizando ferramentas atuais

Neste tutorial irémos explicar como efetuar o build root utilizando os seguintes recursos:

- Ubuntu 24.04 e 24.04.1
- [Arm GNU 13.3.rel1-x86_64-arm-none-linux-gnueabihf](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
- [Buildroot 2024.08.1.tar.xz](https://buildroot.org/downloads/)


A utilização das ferramentas atuais permite entender e facilitar a contrução dos arquivos de sistemas de forma atualizada.

### 1. Inicializando

Instale os packages necessários:
```
sudo apt update
sudo apt install flex
sudo apt install bison
sudo apt install libncurses5-dev
sudo apt install g++
sudo apt install bzip2
sudo apt install git
sudo apt install libssl-dev
```

Primeiramente, baixe os recursos citados acima (exceto Linux SoCFPGA, cujo link será usado no menuconfig do buildroot). Crie um diretório e coloque os arquivos extraídos nele (em caso de repositório git, dê git clone neste diretõrio). Em seguida começaremos pelas configurações do buildroot:

1. Acesse o diretorio do Buildroot
2. rode o comando: 
```
make ARCH=arm ARM_GCC=[insert_toolchain_path]/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-linux-gnueabihf menuconfig
```



O comando anterior irá abrir a configuração do Buildroot. Iremos configurar os recursos existentes para criar o file system e compilar o kernel. Segue abaixo as configurações recomendadas para uso em nossa pĺaca de desenvolvimento.

### 2. Configuração do root file system

1. Acesse no Main Menu -> Target Options:
    - Target Architecture: ARM (little endian)
    - Target Architecture Variant: cortex-A9
    - Enable NEON SIMD extension support (aperte Y)
    - Enable VFP extension support (aperte Y)
    - Floating point strategy: NEON

2. Acesse no Main Menu -> Toolchain:
    - Toolchain type: External toolchain
    - Toolchain: Custom toolchain
    - Toolchain path: $(ARM_GCC)
    - Toolchain prefix: $(ARCH)-none-linux-gnueabihf 
        
        Para essa etapa, acesse o diretório da pasta e abre no terminal, Por fim execute o comando PWD para ter o caminho certo e coloque na configuração do buildroot.
    - External toolchain gcc version: 13.x
    - External toolchain kernel headers series 4.20.x
    - External toolchain C library: glibc
    - Enable: Toolchain has SSP support
    - Disable: Toolchain doesn't have RPC support
    - Enable: Toolchain has C++ support
    As opções abaixo foram selecionadas, pois o GNU tem supporte para, e caso contrário um erro acontece durante a construção do arquivo de sistema:
    - Enable: Toolchain has Fortran support
    - Enable: Toolchain has OpenMP support

3. Acesse no Main Menu -> System Configuration:
    - System hostname: Escolha o nome do Host
    - System banner: BEM VENIDOS AO SISTEMA EMBARCADO AVANÇADO (de seu nome)

4. Acesse no Main Menu -> Kernel
    - Enable: Linux Kernel
    - Kernel version: Custom Git repository
    - URL of custom repository: https://github.com/altera-opensource/linux-socfpga
    - Custom repository version: socfpga-6.6.22-lts
    - Defconfig name: socfpga


### 3. Gerando o Root File System e o zImage

Apos efetuar e salvar as configurações do buildroot, o comando abaixo ira gerar a imagem do kernel:

```
export ARM_GCC=[insert_toolchain_path]/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-linux-gnueabihf
make ARCH=arm all -j 8
```

- Na área do insert_toolchain_path coloque o caminho do diretório onde deixou a pasta [Arm GNU 13.3.rel1-x86_64-arm-none-linux-gnueabihf](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) após extração.


### 4. Passando o File System para o SDCard

O file system zipado gerado está no diretório do seu buildroot/output/images! Apague o file system atual, e extraia os arquivos zipados gerados para seu SDcard.

```
sudo rm -r /media/[seu_usuario]/[partição_do_sdcard_rfs]/
sync
sudo tar xvf rootfs.tar -C /media/[seu_usuario]/[partição_do_sdcard_rfs]/
sync
```


### 5. Passando a imagem do kernel para o SDCard

Copie o arquivo zImage para a partição do pendrive de 500 MB, substituindo o zImage antigo.


### 6. Executando

Coloque o SDCard em sua placa de desenvolvimento e execute o comando abaixo:

screen /dev/ttyUSB0 115200,cs8

Lembre-se do usuário configurado e sua senha. Em seguida o seu kernel estará em execução!



### Facilitando

Para facilitar a compilação do kernel, criamos um script Makefile para executar o buildroot com as configurações citadas antariormente, presente no arquivo .config abaixo. Esse arquivo Make deverá estar no mesmo diretório do buildroot, enquanto o .config deverá estar na raíz do buildroot. Vale mencionar que o .config é a configuração efetuada na etapa 2, sem essas configuração não é possível criar o file system. Geramos esse arquivo para agilizar as etapas.

Já no arquivo Make, você precisa alterar o caminho do user da maquina e das partições do SDCard, para que seja reconhecido na hora de executar o comando. Como nos exemplos abaixo:

```
USER = [seu_ususario]
PARTITION_ROOTFS = XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
PARTITION_ZIMAGE = XXXX-XXXX 
HOME_PATH = /home/$(USER)/[o_caminho]/[para]/[o_diretorio]/[do_build_root]
```

O arquivo Makefile encapsula as seguintes funcionalidades:

- Baixa requerimentos

- Compila o kernel e o root file system

- Transferencia o file system e o kernel pro SDCard(JÁ CONECTADO COM O PEN-DRIVE EM SUA MÁQUINA, SE FOR RODAR APENAS O make)


### Executando o Makefile

Execute os seguintes comandos:

1. O make install irá baixar todas as dependências e copia o .config para dentro do buildroot. Dependências:

- Necessário que o .config esteja na mesma pasta do Makefile.

```
make install
```

2. O make build irá gerar o kernel e o root file system.

```
make build
```

3. O make remove é necessário para remoção do arquivo root file system, devido ao erro que pode ocorrer após execução mesmo que feita correta. É importante checar os arquivos internos do SDCard, como confirmação de que o comando foi efetivo.

```
make remove
```


4. O make deploy, envia o Kernel e o root file system para o SDCard. Dependências:

- Necessário a conexão com o Pen-drive(SDCard).

```
make deploy
```

### Referências

- [Linux SoCFPGA](https://github.com/altera-opensource/linux-socfpga)


