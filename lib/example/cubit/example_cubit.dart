import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'example_state.dart';

class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit() : super(const ExampleState()) {
    initItemBox();
  }

  Future<void> initItemBox() async {
    emit(state.copyWith(
      initialLoad: true,
    ));

    await Future.delayed(Durations.extralong4);
    final listOfBox = List<ItemBox>.generate(
      20,
      (i) => ItemBox(
        name: 'ItemBox $i',
      ),
    );

    emit(state.copyWith(
      listBox: listOfBox,
      initialLoad: false,
    ));
  }

  Future<void> refresh() async {
    await Future.delayed(Durations.extralong4);
    final listOfBox = List<ItemBox>.generate(
      20,
      (i) => ItemBox(
        name: 'ItemBox $i',
      ),
    );

    emit(state.copyWith(
      listBox: listOfBox,
      initialLoad: false,
    ));
  }

  Future<void> loadMore() async {
    emit(state.copyWith(
      loading: true,
    ));

    await Future.delayed(Durations.extralong4);
    final listOfBox = List<ItemBox>.generate(
      10,
      (i) => ItemBox(
        name: 'ItemBox ${i * state.listBox.length}',
      ),
    );

    final temp = state.listBox;
    temp.insertAll(temp.length, listOfBox);

    emit(state.copyWith(
      listBox: temp,
      loading: false,
    ));
  }
}
