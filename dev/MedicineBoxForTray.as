class MedicineBoxForTray extends MedicineBox{
	// Οεπεξοπεδελενθε
	public function getType():Number{
		return 6;
	}
	// Οεπεξοπεδελενθε
	private function acceptMedBox(gameObject1, gameObject2):Boolean{
		return (gameObject1.getType()==6 && gameObject2.getType()==5);
	}
}