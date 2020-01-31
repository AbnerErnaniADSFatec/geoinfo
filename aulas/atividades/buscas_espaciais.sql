-- ==> Consultas de Proximidade
-- 1. Qual UF encontra-se na localização de longitude -44.29 e la2tude -18.61?
SELECT nome, sigla, regiao, ST_Transform(geom, 4326) from uf_2018
where ST_Contains(
	geom,
	ST_GeomFromText( 'POINT(-44.29 -18.61)', 4674)
);
SELECT ST_Transform(ST_GeomFromText( 'POINT(-44.29 -18.61)', 4674), 4326);

-- ==> Junção Espacial
-- 1. Quais UF possuem geometrias com alguma interação espacial com o retângulo de coordenadas:
--- * xmin: -54.23 xmax: -43.89
--- * ymin: -12.90 ymax: -21.49
SELECT nome, sigla, ST_Transform(geom, 4326) from uf_2018
WHERE ST_Intersects(
	ST_Envelope(ST_GeomFromText( 'MULTIPOINT( ( -54.23 -12.90), (-43.89 -21.49 ) )', 4674)),
	geom
);
SELECT ST_Transform(ST_Envelope(ST_GeomFromText( 'MULTIPOINT( ( -54.23 -12.90), (-43.89 -21.49 ) )', 4674)), 4326);

-- 2. Quais os municípios num raio de 2 graus da coordenada:
-- * longitude: -43.59
-- * Latitude.: -20.32
SELECT nome, uf, regiao, ST_Transform(geom,4326) FROM municipios_2018
WHERE ST_DWithin(
	geom,
	ST_GeomFromText('POINT(-43.59 -20.32)', 4674),
	2.0
);
SELECT ST_Transform(ST_GeomFromText('POINT(-43.59 -20.32)', 4674), 4326);
SELECT ST_Transform(
	ST_Buffer(
		ST_GeomFromText('POINT(-43.59 -20.32)', 4674),
		2.0
	),
	4326
);

SELECT nome, uf, regiao, ST_Transform(geom, 4326)
FROM municipios_2018
WHERE ST_Distance(
	ST_GeomFromText('POINT(-43.59 -20.32)', 4674),
	geom
) <= 2;

-- 3. Quais as áreas de terras indígenas no Estado do Tocanins?
SELECT estado.nome, estado.sigla, ti.nome, ST_Transform(ti.geom, 4326)
FROM uf_2018 estado, terras_indigenas ti
WHERE ST_Intersects(estado.geom, ti.geom) AND estado.nome = 'TOCANTINS';

-- 4. Quantos focos de incêndio na vegetação foram detectados em Unidades de Conservação Estaduais do Estado do Tocantins em 2019?
SELECT estado.nome AS estado, uc.nome AS uc_nome, ST_Transform(uc.geom, 4326) AS unidades_conservacao
FROM uf_2018 estado, unidades_conservacao uc
WHERE ST_Intersects(
	ST_Transform(estado.geom, 4674),
	ST_Transform(uc.geom, 4674)
) AND estado.nome  = 'TOCANTINS';

SELECT estado.nome AS estado, uc.nome AS uc_nome, foco.datahora, foco.datahora, ST_Transform(foco.geom, 4326) AS foco
FROM uf_2018 estado, unidades_conservacao uc, focos_2019 foco
WHERE foco.estado = estado.nome AND estado.nome  = 'TOCANTINS' AND uc.jurisdicao = 'Estadual'  AND
ST_Intersects(
	ST_Transform(estado.geom, 4674),
	ST_Transform(uc.geom, 4674)
) AND 
ST_Contains(
	ST_Transform(uc.geom, 4674),
	ST_Transform(foco.geom, 4674)
);

SELECT uc.nome AS nome, COUNT(*) AS total_focos
FROM focos_2019 foco, unidades_conservacao uc, uf_2018 uf
WHERE uf.nome = 'TOCANTINS' AND
ST_Intersects(
	ST_Transform(uf.geom, 4674),
	ST_Transform(uc.geom, 4674)
) AND uc.jurisdicao = 'Estadual' AND
ST_Contains(
	ST_Transform(uc.geom, 4674),
	ST_Transform(foco.geom, 4674)
) GROUP BY uc.id, uc.nome ORDER BY total_focos DESC;

-- 5. Quais os municípios vizinhos de Ouro Preto em Minas Gerais?
SELECT municipio.nome, municipio.uf, ST_Transform(municipio.geom, 4326)
FROM municipios_2018 ouro_preto, municipios_2018 municipio
WHERE ST_Touches(
	municipio.geom,
	ouro_preto.geom
) AND ouro_preto.nome = 'OURO PRETO' AND municipio.uf = 'MINAS GERAIS';

-- 6. Quantos focos de incêndio na vegetação foram detectados mensalmente em Unidades de Conservação Estaduais do Estado do Tocantins ao longo de 2017?
SELECT foco.*
FROM focos_2019 foco
INNER JOIN unidades_conservacao uc on ST_Intersects(
	ST_Transform(foco.geom, 4674),
	ST_Transform(uc.geom, 4674)
)
INNER JOIN uf_2018 uf on ST_Intersects(
	ST_Transform(uf.geom, 4674),
	ST_Transform(uc.geom, 4674)
) WHERE uf.nome = 'TOCANTINS' AND foco.estado = uf.nome;

-- ==> Overlay de Mapas
-- 1. Quais os tipos de solo do Estado do Tocantins?
SELECT solo.relevo, solo.erosao, solo.ordem, ST_Transform(solo.geom, 4326)
FROM uf_2018 uf, pedologia_2017 solo
WHERE uf.nome = 'TOCANTINS' AND
ST_Intersects(uf.geom, solo.geom);

-- 2. Qual o tipo de solo predominante em Ouro Preto?
SELECT solo.relevo, solo.erosao, solo.ordem,  ST_Transform(solo.geom, 4326)
FROM municipios_2018 municipio, pedologia_2017 solo
WHERE municipio.nome = 'OURO PRETO' AND
ST_Intersects(municipio.geom, solo.geom);

SELECT solo.ordem, MAX(solo.val_ncompo) AS max_solo
FROM municipios_2018 municipio, pedologia_2017 solo
WHERE municipio.nome = 'OURO PRETO' AND
ST_Intersects(municipio.geom, solo.geom) AND solo.ordem IS NOT NULL
GROUP BY solo.ordem ORDER BY max_solo DESC;

-- ==> Consultas Gerais
-- 2. Gerar o mapa de regiões do Brasil a partir do mapa de Unidades Federativas.
SELECT uf.regiao, ST_Transform(ST_Union(uf.geom), 4326) FROM uf_2018 uf GROUP BY uf.regiao;

-- Contar quantidade de focos por biomas
SELECT bioma.bioma, COUNT(foco.*) AS quant_focos
FROM biomas bioma, focos_2019 foco
GROUP BY bioma.bioma ORDER BY quant_focos DESC;


















