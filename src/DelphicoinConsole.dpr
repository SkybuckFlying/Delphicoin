program DelphicoinConsole;

{

Delphicoin Console

version 0.01 created on 25 december 2020 by Skybuck Flying !

First of all Happy 2020 Christmas everybody ! =D

Second of all Kill This Fucking Corona Virus already ! LOL.

Finally:

Welcome to the Delphicoin Console program.

This simple project is simply ment to aid the conversion from bitcoin/c/c++
to delphi code and very maybe run something.

But for now it's mainly ment/focused on simply adding units to the project
for compilation/compiler/compile assistance ! =D

May 2021 be a better year for us all ! ;) =D

Though 2020 was a nice year for bitcoin reaching an all
time high of 20.000 USA dollars !

}

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Unit_TBlockFileInfo in 'Chain\Unit_TBlockFileInfo.pas',
  Unit_TBlockIndex in 'Chain\Unit_TBlockIndex.pas',
  Unit_TBlockStatus in 'Chain\Unit_TBlockStatus.pas',
  Unit_TDiskBlockIndex in 'Chain\Unit_TDiskBlockIndex.pas',
  Unit_TChain in 'Chain\Unit_TChain.pas',
  Unit_TBlockLocator in 'Primitives\Block\Unit_TBlockLocator.pas',
  Unit_TBlock in 'Primitives\Block\Unit_TBlock.pas',
  Unit_TBlockHeader in 'Primitives\Block\Unit_TBlockHeader.pas',
  Unit_TTransactionRef in 'Primitives\Transaction\Unit_TTransactionRef.pas',
  Unit_TOutPoint in 'Primitives\Transaction\Unit_TOutPoint.pas',
  Unit_TTxIn in 'Primitives\Transaction\Unit_TTxIn.pas',
  Unit_TTxOut in 'Primitives\Transaction\Unit_TTxOut.pas',
  Unit_TTransaction in 'Primitives\Transaction\Unit_TTransaction.pas',
  Unit_TMutableTransaction in 'Primitives\Transaction\Unit_TMutableTransaction.pas',
  Unit_TGenTxid in 'Primitives\Transaction\Unit_TGenTxid.pas',
  Unit_UnserializeTransaction in 'Primitives\Transaction\Unit_UnserializeTransaction.pas',
  Unit_SerializeTransaction in 'Primitives\Transaction\Unit_SerializeTransaction.pas';

procedure Main;
begin
	writeln('Delphicoin console started');


	writeln('Delphicoin console finished');
end;

begin
  try
	Main;
  except
	on E: Exception do
	  Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
