extends Node2D
var valid = false
var capturable = false

func black():
	$base.set_frame(0)

func white():
	$base.set_frame(1)

func isValid():
	return valid

func isCapturable():
	return capturable

func showValid():
	$validMove.show()
	$invalidMove.hide()
	valid = true

func hideValid():
	$validMove.hide()
	valid = false

func showInvalid():
	$invalidMove.show()
	await get_tree().create_timer(1.0).timeout
	$invalidMove.hide()

func showEnemyMove():
	$enemyMove.show()

func hideEnemyMove():
	$enemyMove.hide()

func enableCapture():
	$validMove.hide()
	$invalidMove.hide()
	$capture.show()
	capturable = true

func disableCapture():
	$capture.hide()
	capturable = false
