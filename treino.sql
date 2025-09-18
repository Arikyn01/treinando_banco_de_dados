drop database if exists questionario_treino;
create database questionario_treino;
use questionario_treino;

drop table if exists usuario;
create table usuario(
idUsuario int not null auto_increment primary key,
nome varchar(30) not null,
pontuacao_total int not null default 0
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
idUsuario int not null,
idAlternativas int not null,
idQuestoes int not null,
correta tinyint not null default 0,
idResultado int not null,
constraint fk_respostas_idAlternativas foreign key (idAlternativas) references alternativas (idAlternativas),
constraint fk_respostas_idQuestoes foreign key (idQuestoes) references questoes (idQuestoes),
constraint fk_respostas_idUsuario foreign key (idUsuario) references usuario (idUsuario),
constraint fk_respostas_idResultado foreign key (idResultado) references resultado (idResultado) 
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select 
u.idUsuario, sum(r.pontuacao) as pontuacao_total
from usuario u
join resultado r on r.idUsuario = u.idUsuario group by u.idUsuario; -- verificar

select 
u.nome,
count(*)
from respostas r
join usuario u on u.idUsuario = r.idUsuario
join questoes q on q.idQuestoes = r.idQuestoes  
where r.correta = 1
group by u.nome;

select u.idUsuario, q.idQuestionario from usuario u 
inner join resultado q on u.idUsuario = q.idUsuario;

create or replace view ranking as 
select
u.idUsuario,
sum(r.tempo) as 'Tempo total',
sum(r.pontuacao) as pontuacao_total,
rank() over( order by sum(r.pontuacao) desc, sum(tempo) asc) as posicao
from usuario u 
join resultado r on r.idUsuario = u.idUsuario
group by u.idUsuario;

select * from ranking order by posicao;

create or replace view ranking_questionario as 
select
u.idUsuario,
r.pontuacao,
r.idQuestionario,
r.tempo,
rank() over(partition by r.idQuestionario order by r.pontuacao desc, tempo asc) as posicao
from usuario u 
join resultado r on r.idUsuario = u.idUsuario;
drop procedure if exists in_resultados

delimiter $$
create procedure in_resultados (p int, idu int)
begin
update resultado
set pontuacao = pontuacao + (p * ( select 
								  count(rs.correta) 
								  from respostas rs 
                                  where rs.correta = 1 
                                  and rs.idUsuario = idu))
where idUsuario = idu;
 

end $$
delimiter ;


drop procedure if exists Historicos;

delimiter $$
create procedure Historicos (id int)
begin
select
rk.posicao,
r.idUsuario,
r.idQuestionario,
r.pontuacao,
r.tempo,
r.dataexecucao
from resultado r
join ranking rk on rk.idUsuario = r.idUsuario
order by rk.posicao;
end $$
delimiter ;



drop procedure if exists top;
delimiter $$
create procedure top ()
begin
select
q.idUsuario,
sum(pontuacao) as pontuacao_total,
q.idQuestionario,
Rank() over(order by sum(pontuacao) desc) as 'Top 5'
from resultado q
join usuario u on u.idUsuario = q.idUsuario
order by pontuacao_total desc
limit 5;
end$$
 delimiter ;
 
call Historicos (2);
