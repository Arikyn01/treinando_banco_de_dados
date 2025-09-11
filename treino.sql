drop database if exists questionario_treino;
create database questionario_treino;
use questionario_treino;

drop table if exists usuario;
create table usuario(
idUsuario int not null auto_increment primary key,
nome varchar(30) not null,
pontuacao int not null default 0
);

drop table if exists questionario;
create table questionario(
idQuestionario int not null primary key auto_increment,
nome varchar(30) not null
);

drop table if exists questoes;
create table questoes(
idQuestoes int not null primary key auto_increment,
idQuestionario int not null,
perguntas text not null,
constraint fk_questoes_idQuestionario foreign key (idQuestionario) references questionario (idQuestionario) on delete cascade
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

drop table if exists alternativas;
create table alternativas(
idAlternativas int not null primary key auto_increment,
idQuestoes int not null,
testo text not null,
correta tinyint not null default 0,
constraint fk_alternativas_idQuestoes foreign key (idQuestoes) references questoes (idQuestoes) 
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

drop table if exists resultado;
create table resultado(
idResultado int not null primary key auto_increment,
idUsuario int not null,
idQuestionario int not null,
pontuacao int not null default 0,
tempo int not null default 0,
dataexecucao datetime,
constraint fk_resultado_idUsuario foreign key (idUsuario) references usuario (idUsuario),
constraint fk_resultado_idQuestionario foreign key (idQuestionario) references questionario (idQuestionario)
);

drop table if exists respostas;
create table respostas(
idRespostas int not null primary key auto_increment,
idAlternativas int not null,
idQuestoes int not null,
correta tinyint not null default 0,
idResultado int not null,
constraint fk_respostas_idAlternativas foreign key (idAlternativas) references alternativas (idAlternativas),
constraint fk_respostas_idQuestoes foreign key (idQuestoes) references questoes (idQuestoes),
constraint fk_respostas_idResultado foreign key (idResultado) references resultado (idResultado) 
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into usuario(nome, pontuacao)
values ('nome','100'),
('Ariel','200'),
('Matheus','100'),
('Danilo','300'),
('Emanuel','400');

insert into questionario (nome)
values ('matemática'),
('história'),
('geografia'),
('artes'),
('portugues');

insert into questoes (perguntas)
values ('Banana?'),
('Abacate?'),
('tangerina?'),
('?-?'),
('é foda?');

insert into alternativas (testo, correta)
values ('leão',0),
('cachorro',1),
('tigre',1),
('doninha',0);

select
u.pontuacao,
u.usuario
from usuario u
join resultado r on r.pontuacao = u.pontuacao;







