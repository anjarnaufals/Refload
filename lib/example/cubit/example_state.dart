part of 'example_cubit.dart';

class ExampleState extends Equatable {
  const ExampleState({
    this.listBox = const [],
    this.loading = false,
    this.initialLoad = false,
  });

  final List<ItemBox> listBox;
  final bool loading;
  final bool initialLoad;

  @override
  List<Object> get props => [
        listBox,
        loading,
        false,
      ];

  ExampleState copyWith({
    List<ItemBox>? listBox,
    bool? loading,
    bool? initialLoad,
  }) {
    return ExampleState(
      listBox: listBox ?? this.listBox,
      loading: loading ?? this.loading,
      initialLoad: initialLoad ?? this.initialLoad,
    );
  }
}

class ItemBox extends Equatable {
  final String? name;
  const ItemBox({
    this.name,
  });

  @override
  List<Object?> get props => [
        name,
      ];

  ItemBox copyWith({
    String? name,
  }) {
    return ItemBox(
      name: name ?? this.name,
    );
  }
}
