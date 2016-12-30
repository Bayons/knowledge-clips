;Sergio Garcia Prado
;Oscar Fernandez Angulo
;03/01/2017

;Ejercicio 3.
;
;Modelar el asistente de diagnostico para enfermedades
;cardiovasculares basado en probabilidad.



;
;
; Definicion de plantillas para el formalismo O-A-V-C:
; ******************************************************************************

(deftemplate oavc-u
	"Plantilla para hechos univaluados"
	(slot objeto (type SYMBOL))
	(slot atributo(type SYMBOL))
	(slot valor)
	(slot factor (type FLOAT) (range -1.0 +1.0))
)


(deftemplate oavc-m
	"Plantilla para hechos multivaluados"
	(slot objeto (type SYMBOL))
	(slot atributo(type SYMBOL))
	(slot valor)
	(slot factor (type FLOAT) (range -1.0 +1.0))
)



(defrule duplicar-hechos
	(declare (salience 10000))
=>
	(set-fact-duplication TRUE)
)



(defrule acumula-positivos-univaluados
	(declare (salience 10000))
	?fact1 <- (oavc-u
				(objeto ?o)
				(atributo ?a)
				(valor ?v)
				(factor ?f1&:(>= ?f1 0)&:(< ?f1 1))
	)
	?fact2 <- (oavc-u (objeto ?o)
				(atributo ?a)
				(valor ?v)
				(factor ?f2&:(>= ?f2 0)&:(< ?f2 1))
	)
	(test (neq ?fact1 ?fact2))
=>
	(retract ?fact1)
	(bind ?f3 (+ ?f1 (* ?f2 (- 1 ?f1))))
	(modify ?fact2 (factor ?f3))
)



(defrule acumula-positivos-multivaluados
	(declare (salience 10000))
    ?fact1 <- (oavc-m (objeto ?o)
				(atributo ?a)
				(valor ?v)
				(factor ?f1&:(>= ?f1 0)&:(< ?f1 1))
	)
	?fact2 <- (oavc-m (objeto ?o)
				(atributo ?a)
				(valor ?v)
				(factor ?f2&:(>= ?f2 0)&:(< ?f2 1))
	)
	(test (neq ?fact1 ?fact2))
=>
	(retract ?fact1)
	(bind ?f3 (+ ?f1 (* ?f2 (- 1 ?f1))))
	(modify ?fact2 (factor ?f3))
)


;
;
; Hechos
; ******************************************************************************


;
;Hechos Marta:
(deffacts hechos_Marta
	(oavc-u (objeto marta) (atributo genero) (valor mujer) (factor 1.0))
	(oavc-u (objeto marta) (atributo edad) (valor 12) (factor 1.0))
	(oavc-u (objeto marta) (atributo peso) (valor obeso) (factor 1.0))
	(oavc-m (objeto marta) (atributo sintomas) (valor fiebre) (factor 0.6))
	(oavc-m (objeto marta) (atributo observacion) (valor rumor_diastolico) (factor 0.8))
	(oavc-u (objeto marta) (atributo sistolica) (valor 150) (factor 1.0))
	(oavc-u (objeto marta) (atributo diastolica) (valor 60) (factor 1.0))
)


;
;Hechos Luis:
(deffacts hechos_Luis
	(oavc-u (objeto luis) (atributo genero) (valor hombre) (factor 1.0))
	(oavc-u (objeto luis) (atributo edad) (valor 49) (factor 1.0))
	(oavc-u (objeto luis) (atributo peso) (valor obeso) (factor 0.5))
	(oavc-m (objeto luis) (atributo sintomas) (valor dolor_abdominal) (factor 0.7))
	(oavc-m (objeto luis) (atributo sintomas) (valor calambres_pierna_andar) (factor 0.6))
	(oavc-m (objeto luis) (atributo observacion) (valor rumor_abdominal) (factor 0.6))
	(oavc-m (objeto luis) (atributo observacion) (valor masa_pulsante_abdomen) (factor 0.8))
	(oavc-u (objeto luis) (atributo sistolica) (valor 130) (factor 1.0))
	(oavc-u (objeto luis) (atributo diastolica) (valor 90) (factor 1.0))
)


;
;Hechos Andres:
(deffacts hechos_andres
	(oavc-u (objeto andres) (atributo genero) (valor hombre) (factor 1.0))
	(oavc-u (objeto andres) (atributo edad) (valor 52) (factor 1.0))
	(oavc-u (objeto andres) (atributo peso) (valor obeso) (factor 0.7))
	(oavc-m (objeto andres) (atributo fuma) (valor 18) (factor 1.0))
	(oavc-u (objeto andres) (atributo sistolica) (valor 125) (factor 1.0))
	(oavc-u (objeto andres) (atributo diastolica) (valor 85) (factor 1.0))



;
;
;Reglas para el diagnostico:
; ******************************************************************************



(defrule R1 "calcula presion pulso"
	(oavc-u
		(objeto ?pac) (atributo sistolica) (valor ?sis) (factor ?f1))
	(oavc-u
		(objeto ?pac) (atributo diastolica) (valor ?dia) (factor ?f2))
	(test
		(> (min ?f1 ?f2) 0.2))
	=>
	(bind
		?pul (- ?sis ?dia))
	(assert (oavc-u
		(objeto ?pac) (atributo pulso) (valor ?pul) (factor 1.0)))
)




(defrule R2a "paciente de riesgo"
	(oavc-u
		(objeto ?pac) (atributo peso) (valor obeso) (factor ?f) (factor ?f1))
	(test
		(> (min ?f1) 0.2))
	=>
	(assert (oavc-m
		(objeto ?pac) (atributo condicion) (valor paciente_riesgo) (factor 0.8)))
)



(defrule R2b "paciente de riesgo"
	(oavc-u
		(objeto ?pac) (atributo fuma) (valor ?y &:(> ?y 15)) (factor ?f1))
	(test
		(> (min ?f1) 0.2))
	=>
	(assert (oavc-m
		(objeto ?pac) (atributo condicion) (valor paciente_riesgo) (factor 0.8)))
)



(defrule R2c "paciente de riesgo"
	(oavc-u
		(objeto ?pac) (atributo edad) (valor ?y &:(> ?y 50)) (factor ?f1))
	(test
		(> (min ?f1) 0.2))
	=>
	(assert (oavc-m
		(objeto ?pac) (atributo condicion) (valor paciente_riesgo) (factor 0.6)))
)




(defrule R3 "aneurisma en la arteria abdominal"
	(oavc-m
		(objeto ?x) (atributo observacion) (valor rumor_abdominal) (factor ?f1))
	(oavc-m
		(objeto ?x) (atributo observacion) (valor masa_pulsante_abdomen) (factor ?f2))
	(test
		(> (min ?f1 ?f2) 0.2))
	=>
	(assert (oavc-m
		(objeto ?x) (atributo diagnostico) (valor aneurisma_arteria_abdominal) (factor 0.8)))
)




(defrule R4a "regurgitacion aortica"
	(oavc-u
		(objeto ?x) (atributo sistolica) (valor ?y &:(> ?y 140)) (factor ?f1))
	(oavc-u
		(objeto ?x) (atributo pulso) (valor ?z&:(> ?z 50)) (factor ?f2))
	(oavc-m
		(objeto ?x) (atributo observacion) (valor rumor_sistolico) (factor ?f3))
	(oavc-m
		(objeto ?x) (atributo observacion) (valor dilatacion_corazon) (factor ?f4))
	(test
		(> (min ?f1 ?f2 ?f3 ?f4) 0.2))
	=>
	(assert (oavc-m
		(objeto ?x) (atributo diagnostico) (valor regurgitacion_aortica) (factor 0.7)))
)



(defrule R4b "regurgitacion aortica"
	(oavc-u
		(objeto ?x) (atributo sistolica) (valor ?y &:(> ?y 140)) (factor ?f1))
	(oavc-u
		(objeto ?x) (atributo pulso) (valor ?z&:(> ?z 50)) (factor ?f2))
	(not (oavc-m
		(objeto ?x) (atributo observacion) (valor rumor_sistolico) (factor ?f3)))
	(oav-m
		(objeto ?x) (atributo observacion) (valor dilatacion_corazon) (factor ?f4))
	(test
		(> (min ?f1 ?f2 ?f4) 0.2))
	=>
	(assert
		(oav-m (objeto ?x) (atributo diagnostico) (valor regurgitacion_aortica) (factor 0.7)))
)



(defrule R4c "regurgitacion aortica"
	(oavc-u
		(objeto ?x) (atributo sistolica) (valor ?y &:(> ?y 140))(factor ?f1))
	(oavc-u
		(objeto ?x) (atributo pulso) (valor ?z&:(> ?z 50))(factor ?f2))
	(oavc-m
		(objeto ?x) (atributo observacion) (valor rumor_sistolico)(factor ?f3))
	(not (oavc-m
		(objeto ?x) (atributo observacion) (valor dilatacion_corazon))(factor ?f4))
	(test
		(> (min ?f1 ?f2 ?f3) 0.2))
	=>
	(assert
		(oavc-m (objeto ?x) (atributo diagnostico) (valor regurgitacion_aortica) (factor 0.7)))
)




(defrule R5 "estenosis en la arteria de la pierna"
	(oavc-m(objeto ?x)
		(atributo sintomas) (valor calambres_pierna_andar) (factor ?f1))
	(test
		(> ?f1 0.2))
	=>
	(assert (oavc-m
		(objeto ?x) (atributo diagnostico) (valor estenosis_arteria_pierna) (factor 0.9)))
)




(defrule R6 "arterioesclerosis"
	(oavc-m
		(objeto ?x) (atributo diagnostico) (valor estenosis_arteria_pierna) (factor ?f1) )
	(oavc-m
		(objeto ?x) (atributo condicion) (valor paciente_riesgo) (factor ?f2))
	(test
		(> (min ?f1 ?f2) 0.2))
	=>
	(assert (oavc-m
		(objeto ?x) (atributo diagnostico) (valor arterioesclerosis) (factor 0.8)))
)





;
;
; Imprimir el diagnostico
; ******************************************************************************

(defrule imprimir_diagnostico
	(declare
		(salience -10000))
	(oavc-m
		(objeto ?pac) (atributo diagnostico) (valor ?diag) (factor ?f))
	=>
	(printout t
		?pac " padece " ?diag " con un factor de certeza de " ?f crlf)
)
