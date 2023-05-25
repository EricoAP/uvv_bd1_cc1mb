-- Apagar banco de dados com o mesmo nome
DROP DATABASE IF EXISTS uvv;

-- Apagar usuário com o mesmo nome
DROP USER IF EXISTS Erico;

-- Criar usuário
CREATE USER Erico WITH
CREATEDB
CREATEROLE
ENCRYPTED PASSWORD '123';

-- Criar o banco de dados
CREATE DATABASE uvv
OWNER Erico
TEMPLATE template0
ENCODING 'UTF8'
LC_COLLATE 'pt_BR.UTF-8'
LC_CTYPE 'pt_BR.UTF-8'
ALLOW_CONNECTIONS true;

-- Conectar ao banco de dados
\c uvv

-- Criar schema lojas
CREATE SCHEMA lojas AUTHORIZATION Erico;
ALTER SCHEMA lojas OWNER TO Erico;

-- Definir o caminho de pesquisa do usuário Erico
ALTER USER Erico SET SEARCH_PATH TO lojas, "$user", public;

----------------------
--criação de tabelas--
----------------------

--criar a tabela produtos
CREATE TABLE public.produtos (
    produto_id                     NUMERIC(38)      NOT NULL ,
    nome                           VARCHAR(255)     NOT NULL ,
    preco_unitario                 NUMERIC(10,2)             ,
    detalhes                       BYTEA                     ,
    imagem                         BYTEA                     ,
    imagem_mime_type               VARCHAR(512)              ,
    imagem_arquivo                 VARCHAR(512)              ,
    imagem_charset                 VARCHAR(512)              ,
    imagem_ultima_atualizacao      DATE                      ,
    CONSTRAINT pk_produtos PRIMARY KEY (produto_id)
);

ALTER TABLE public.produtos
ADD CONSTRAINT produtos_preco_positivo
CHECK (preco_unitario >= 0); 

--criar comentarios da tabela produtos
COMMENT ON COLUMN public.produtos.produto_id                   IS 'numero do id do produto';
COMMENT ON COLUMN public.produtos.nome                         IS 'nome do produto';
COMMENT ON COLUMN public.produtos.preco_unitario               IS 'preço unitario do produto';
COMMENT ON COLUMN public.produtos.detalhes                     IS 'detalhes do produto';
COMMENT ON COLUMN public.produtos.imagem                       IS 'imagem do produto';
COMMENT ON COLUMN public.produtos.imagem_mime_type             IS 'imagem mime type do produto';
COMMENT ON COLUMN public.produtos.imagem_arquivo               IS 'arquivo da imagem do produto';
COMMENT ON COLUMN public.produtos.imagem_charset               IS 'imagem charset do produto';
COMMENT ON COLUMN public.produtos.imagem_ultima_atualizacao    IS 'data da ultima atualização da imagem do produto';

--criar a tabela lojas
CREATE TABLE public.lojas (
    loja_id                     NUMERIC(38)    NOT NULL ,
    nome                        VARCHAR(255)   NOT NULL ,
    endereco_web                VARCHAR(100)            ,
    endereco_fisico             VARCHAR(512)            ,
    latitude                    NUMERIC                 ,
    longitude                   NUMERIC                 ,
    logo                        BYTEA                   ,
    logo_mime_type              VARCHAR(512)            ,
    logo_arquivo                VARCHAR(512)            ,
    logo_charset                VARCHAR(512)            ,
    logo_ultima_atualizacao     DATE                    ,
    CONSTRAINT pk_lojas PRIMARY KEY (loja_id)
);

ALTER TABLE public.lojas
ADD CONSTRAINT endereco_check
CHECK (endereco_web IS NOT NULL OR endereco_fisico IS NOT NULL);

--criar comentarios da tabela lojas
COMMENT ON COLUMN public.lojas.loja_id                    IS 'numero do id da loja';
COMMENT ON COLUMN public.lojas.nome                       IS 'nome da loja';
COMMENT ON COLUMN public.lojas.endereco_web               IS 'endereco web da loja';
COMMENT ON COLUMN public.lojas.endereco_fisico            IS 'endereco fisico da loja';
COMMENT ON COLUMN public.lojas.latitude                   IS 'latitude da loja';
COMMENT ON COLUMN public.lojas.longitude                  IS 'longitude da loja';
COMMENT ON COLUMN public.lojas.logo                       IS 'logo da loja';
COMMENT ON COLUMN public.lojas.logo_mime_type             IS 'logo mime type da loja';
COMMENT ON COLUMN public.lojas.logo_arquivo               IS 'arquivo da logo da loja';
COMMENT ON COLUMN public.lojas.logo_charset               IS 'logo charset da loja';
COMMENT ON COLUMN public.lojas.logo_ultima_atualizacao    IS 'data da ultima atualização da logo da loja';

--criar a tabela estoques
CREATE TABLE public.estoques (
    estoque_id         NUMERIC(38)   NOT NULL ,
    loja_id            NUMERIC(38)   NOT NULL ,
    produto_id         NUMERIC(38)   NOT NULL ,
    quantidade         NUMERIC(38)   NOT NULL ,
    CONSTRAINT pk_estoques PRIMARY KEY (estoque_id)
);

--criar comentarios da tabela estoques
COMMENT ON COLUMN public.estoques.estoque_id    IS 'numero do id do estoque';
COMMENT ON COLUMN public.estoques.loja_id       IS 'numero do id do estoque da loja';
COMMENT ON COLUMN public.estoques.produto_id    IS 'numero id do estoque do produto';
COMMENT ON COLUMN public.estoques.quantidade    IS 'numero da quantidade de itens do estoque';

--criar a tabela clientes
CREATE TABLE public.clientes (
    cliente_id    NUMERIC(38)    NOT NULL ,
    email         VARCHAR(255)   NOT NULL ,
    nome          VARCHAR(255)   NOT NULL ,
    telefone1     VARCHAR(20)             ,
    telefone2     VARCHAR(20)             ,
    telefone3     VARCHAR(20)             ,
    CONSTRAINT pk_clientes PRIMARY KEY (cliente_id)
);

--criar comentarios da tabela clientes
COMMENT ON TABLE public.clientes                IS 'tabela clientes';
COMMENT ON COLUMN public.clientes.cliente_id    IS 'numero do id do cliente';
COMMENT ON COLUMN public.clientes.email         IS 'endereço de email do cliente';
COMMENT ON COLUMN public.clientes.nome          IS 'nome completo do cliente';
COMMENT ON COLUMN public.clientes.telefone1     IS 'telefone 1 do cliente';
COMMENT ON COLUMN public.clientes.telefone2     IS 'telefone 2 do cliente';
COMMENT ON COLUMN public.clientes.telefone3     IS 'telefone 3 do cliente';

--criar a tabela envios
CREATE TABLE public.envios (
    envio_id            NUMERIC(38)     NOT NULL ,
    cliente_id          NUMERIC(38)     NOT NULL ,
    loja_id             NUMERIC(38)     NOT NULL ,
    endereco_entrega    VARCHAR(512)    NOT NULL ,
    status              VARCHAR(15)     NOT NULL ,
    CONSTRAINT pk_envios PRIMARY KEY (envio_id)
);

ALTER TABLE public.envios
ADD CONSTRAINT envios_check
CHECK (status IN ('CRIADO', 'ENVIADO', 'TRANSITO', 'ENTREGUE'));

--criar comentarios da tabela envios
COMMENT ON COLUMN public.envios.envio_id            IS 'numero do id do envio';
COMMENT ON COLUMN public.envios.cliente_id          IS 'id do envio';
COMMENT ON COLUMN public.envios.loja_id             IS 'id da loja de envio';
COMMENT ON COLUMN public.envios.endereco_entrega    IS 'endereço de entrega do envio';
COMMENT ON COLUMN public.envios.status              IS 'status do envio';

--criar a tabela pedidos
CREATE TABLE public.pedidos (
    pedido_id          NUMERIC(38)    NOT NULL ,
    data_hora          TIMESTAMP      NOT NULL ,
    status             VARCHAR(15)    NOT NULL ,
    cliente_pedidos    NUMERIC(38)    NOT NULL ,
    loja_pedidos       NUMERIC(38)    NOT NULL ,
    CONSTRAINT pk_pedidos PRIMARY KEY (pedido_id)
);

--criar comentarios da tabela pedidos
COMMENT ON COLUMN public.pedidos.pedido_id          IS 'numero do id do pedido';
COMMENT ON COLUMN public.pedidos.data_hora          IS 'data e hora do pedido';
COMMENT ON COLUMN public.pedidos.status             IS 'status do pedido';
COMMENT ON COLUMN public.pedidos.cliente_pedidos    IS 'numero do cliente do pedido';
COMMENT ON COLUMN public.pedidos.loja_pedidos       IS 'numero da loja do pedido';

ALTER TABLE public.pedidos
ADD CONSTRAINT pedidos_status
CHECK (status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO'));

--criar a tabela pedidos_itens
CREATE TABLE public.pedidos_itens (
    pedido_item_id      NUMERIC(38)       NOT NULL ,
    produto_id          NUMERIC(38)       NOT NULL ,
    numero_da_linha     NUMERIC(38)       NOT NULL ,
    preco_unitario      NUMERIC(10,2)     NOT NULL ,
    quantidade          NUMERIC(38)       NOT NULL ,
    envio_id            NUMERIC(38)                ,
    CONSTRAINT pk_pedidos_itens PRIMARY KEY (pedido_item_id, produto_id)
);

ALTER TABLE public.pedidos_itens
ADD CONSTRAINT pedidos_itens_check
CHECK (preco_unitario >= 0); 

ALTER TABLE public.pedidos_itens
ADD CONSTRAINT pedidos_itens_check2
CHECK (quantidade >= 0); 

ALTER TABLE public.pedidos_itens
ADD CONSTRAINT pedidos_itens_check3
CHECK (numero_da_linha >= 0);

--criar comentarios da tabela pedidos_itens
COMMENT ON COLUMN public.pedidos_itens.pedido_item_id     IS 'numero do id dos itens do pedido';
COMMENT ON COLUMN public.pedidos_itens.produto_id         IS 'numero do id dos produtos dos itens do pedido';
COMMENT ON COLUMN public.pedidos_itens.numero_da_linha    IS 'numero da linha dos itens do pedido';
COMMENT ON COLUMN public.pedidos_itens.preco_unitario     IS 'preço unitario dos itens do pedido';
COMMENT ON COLUMN public.pedidos_itens.quantidade         IS 'quantidade dos itens do pedido';
COMMENT ON COLUMN public.pedidos_itens.envio_id           IS 'numero do id dos itens do envio';

----------------------
--criação das chaves--
----------------------

--criar a chave produtos_estoques_fk
ALTER TABLE public.estoques ADD CONSTRAINT produtos_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES public.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--criar a chave produtos_pedidos_itens_fk
ALTER TABLE public.pedidos_itens ADD CONSTRAINT produtos_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES public.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--criar a chave lojas_pedidos_fk
ALTER TABLE public.pedidos ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY (loja_pedidos)
REFERENCES public.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--criar a chave lojas_envios_fk
ALTER TABLE public.envios ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY (loja_id)
REFERENCES public.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--criar a chave lojas_estoques_fk
ALTER TABLE public.estoques ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES public.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--criar a chave clientes_pedidos_fk
ALTER TABLE public.pedidos ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_pedidos)
REFERENCES public.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--criar a chave clientes_envios_fk
ALTER TABLE public.envios ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY (cliente_id)
REFERENCES public.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--criar a chave envios_pedidos_itens_fk
ALTER TABLE public.pedidos_itens ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES public.envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

--criar a chave pedidos_pedidos_itens_fk
ALTER TABLE public.pedidos_itens ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_item_id)
REFERENCES public.pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;
