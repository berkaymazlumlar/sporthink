class DateRepository {
  DateTime _date = DateTime.now();
  DateTime get date => _date;
  set date(DateTime date) {
    _date = date;
    print("_date setted to $date");
  }
}
