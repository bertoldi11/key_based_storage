# KeyBasedStorage

Projeto feito para processo seletivo. Um banco de dados que recebe comando via uma API HTTP e que gerancia os dados no banco de dados.


## Instalação

## Faça o clone do projeto

### Caso faça uso do [asdf](https://asdf-vm.com/)

``` bash
$ cd key_base_storage
$ asdf install
```

### Caso não faça uso do asfd, instale as versões abaixo do Elixir e Erlang

elixir 1.15.4-otp-25
erlang 25.3.2.8


### Crie o banco de dados

``` bash
$ mix ecto.create 
```

### Rode as migrations para criação das tabelas

``` bash
$ mix ecto.migrate 
```


### Baixe as dependencias do projeto

``` bash
$ mix deps.get 
```


### Inicie o servidor, ele ficará disponível em http://localhost:4000

``` bash
$ mix phx.server 
```

### O sistema está pronto para usar.
A API está pronta para usar e pode ser acessada pela url http://localhost:4000

## Cabeçalho da requisição

Para fazer os testes é necessário adicionar o cabeçalho "Content-Type" com valor "text/plain"
