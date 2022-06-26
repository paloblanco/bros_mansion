pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include mapper.lua
__gfx__
11111111000000000033373000000000000000000000000000000000000000000009090000000000000000000000000000000000000000000000000000000000
1000000000333730033333330000000000888780000000000aaaada000090900a0a9990a0000000000cccc000000000000000000000000000000000000000000
10000000033333333331f1f000888780088888880aaaada0aaaaaaaaa0a9990aaaaaaaaa00cccc00ccc7ccc00000000000000000000000000000000000000000
100000003331f1f044f1f1f00888888888f1f1f0aaaaaaaaaaaf1f10aaaaaaaa0af1f1f0ccc7ccc00c777c770000000000000000000000000000000000000000
1000000044f1f1f04fffffff88f1f1f04ff1f1ffaaaf1f1044ff1f1f0af1f1f0aaf1f1f00c777c77cc7717170000000000000000000000000000000000000000
100000004fffffffffff1fff4ff1f1ff4f1fffff44ff1f1f4f1ffeefaaf1f1f0aafffff0cc7717170c7717170000000000000000000000000000000000000000
10000000ffff1fff0ffff1114f1fffff0ff111114f1ffeeffff11ee1aafffff0aaff1ff00c771717cccff11f0000000000000000000000000000000000000000
100000000ffff11100fffff00ff1111100fffff0fff11ee10ffffff0aaff1ff00a0fff00cccff11f00cffff00000000000000000000000000000000000000000
0000000000fffff00331313000fffff0088c8c800ffffff0aaadada00a0fff000e08880e00cffff0000ccc000000000000000000000000000000000000000000
00000050031331300377317008c88c8008778c70aadaadaaff77ad770e08880e0eefeeee000ccc0000ccffc00000000000000000000000000000000000000000
00000550331331330177117388c88c880c77cc74ffdddddfdd77dd770eeeeeee0fffee8f00ccffc00cc77fc70000000000000000000000000000000000000000
05555560771111773311113377cccc7744cccc4477dddd7733dddd330f8eee8f00e888e00c77ff7700077c770000000000000000000000000000000000000000
06666560771111773310113377cccc7744c0cc4477dddd7733dddd330fff88ff08eeeee80077cc7708cc0cc80000000000000000000000000000000000000000
0000055001100110300000000cc00cc0400000000dddddd03000000000eeeee008e00ee8000c0c00070000000000000000000000000000000000000000000000
000000500330033000000000044004400000000003300330000000000eeeeeee00000000000c0c00000000000000000000000000000000000000000000000000
00000000033303330000000004440444000000000333033300000000008800880000000000087870000000000000000000000000000000000000000000000000
ffffffff006666000066660000ccccc00066660000000000777777770066660000000009000a0000999998880989bbbb06666000000000000000000000000000
ff0000ff06777760061177600c11111c0611116000066000770707776666667700000669aaaa0000999b98889989bbb566556600000000000000000000000000
f000000f6777171667777886c11c1c1c6111c1c600611600770707776660067700006779999960009999b895859999bb65665600000000000000000000000000
000000000677171667117886c11c1c1c0611c1c60611116077777777660660660006777777777600999999955555b9bb65665600000000000000000000000000
000000000677777667777776c111111c06111116061111607700007766066066006777777777776099b90995555559bb66556660000000000000000000000000
f000000f6777887667777776c118881c6111881600611600770770776660066600677770777770608bb9899555bbb55506666006000000000000000000000000
ff0000ff0677886006766760cccccccc061188600006600077777777666666660677777707770776bbb9999955bbbb5500000006000000000000000000000000
ffffffff0066660000600600c0c00c0c006666000000000077777777000000000677777707770776bbb9899955b5bb5500000660000000000000000000000000
0000000008e008e00099990000333300009aa70000aaaa0000aaaa0000aaaa000676777777777776bb9b888995b5bb5500666600000000000000000000000000
000990008888888e09aaaa9003377330009aa7000a8888a00acccca00a9999a00676778777778776bbbb888895bb5b5506777760000000000000000000000000
009aa9008888888e9aa9aaa973377337999aaaa70a8888a00acccca00a9999a006767688888887768bb8888985bbbb9567677676000000000000000000000000
09aaaa902888888e9aa99aa973333337909aaa0a00a8aaa000acaaa000a9aaa067776778888877608898888888bbb99566766766000000000000000000000000
09aaaa902888888e9aa99aa933333333999aaa9a00a888a000accca000a999a0677777778887776088800888889bb99567677676000000000000000000000000
009aa900028888809aa9aaa9071771700099990000a8aaa000acaaa000a9aaa06767777777777600808888888989999506777760000000000000000000000000
000990000028880009aaaa90071771700009a00000a888a000accca000a999a00606677777766000808088888880090000677600000000000000000000000000
000000000002800000999900007777000099a700000aaa00000aaa00000aaa000000066666600000808988888080000000066000000000000000000000000000
2e6dee6dee6dee6dee6dee622e6dee6dee6dee6dee6dee622e6dee622e6dee62ee6dee6d66666666222522220555555000444444444444000000000000000000
2e6dee6dee6dee6dee6dee62e26dee6dee6dee6dee6dee2ee200002de26dee2dee5de56d666dee6d22225222051e815000441111111144000000000000000000
d26dee6dee6dee6dee6dee2d6d2dee6dee6dee6dee6de2d6ee00006dee00006dee5d5e6d6666ee6dee6de56d05be825000441881522144000000000000000000
626dee6dee6dee6dee6dee266de2ee6dee6dee6dee6d2ed6ee00006dee00006dee65ee6d6e666e6dee6d5e6d0555555000441889522144000000000000000000
6d2dee6dee6dee6dee6de2d66d6d2e6dee6dee6dee62d6d6ee00006dee00006dee6d5e6d6e6d666dee65ee6d0581615000441889522144000000000000000000
6d2dee6dee6dee6dee6de2d6de6d626dee6dee6dee2ed6edee00006dee00006dee6de56d6e6de66dee5d5e6d0589615000444444444444000000000000000000
e6d2ee6dee6dee6dee6d2d6ede6d6d2dee6dee6de2d6d6ede26dee2dee00006d222252226e6dee66ee5de56d0555555000441111111144000000000000000000
e6d2ee6dee6dee6dee6d2d6ed6de6de2ee6dee6d2ed6ed6d2e6dee62ee00006d222522226e6dee6dee6dee6d0500005000441111111144000000000000000000
d6de2e6dee6dee6dee62ed6d00000000444544450000000000000001ee00006dd6de6de2666666662ed6ed6d0000000000441111111144000000000000000000
de6d2e6dee6dee6dee62d6ed00000000444544450000000000000010ee00006dde6d6de2666544452ed6d6ed0000000000441111111144000000000000000000
de6de26dee6dee6dee2ed6ed00000000444544450000030000000100ee00006dd56de6d2646644452d6e55ed0000000000444444444444000000000000000000
6d6de26dee6dee6dee2ed6d600000000444544550000303011111111ee00006d6d5de552644664552d55d6d60000000000441111111144000000000000000000
6de6d62dee6dee6de26d6ed600000000444544450000000000010000ee00006d6de556d564456645556d5ed60000000000441111111144000000000000000000
6de6de2dee6dee6de2ed6ed600000000444544450000000000100000ee00006d6556de626445464526ed65d60000000000444444444444000000000000000000
e6d6de622222222226ed6d6e00000000444544450300000001000000ee00006de6d6de626445444526ed6d6e0000000000445500005544000000000000000000
e6de6d622222222226d6ed6e00000000445544453030000011111111ee00006de6de6d626455444526d6ed6e0000000000440000000044000000000000000000
d6de6de2000000012ed6ed6d55555555555555555555555500670067ee00006d0067006700000000000000000000000000000000000000000000000000000000
de6d6de2000000102ed6d6ed588888855cccccc55999999566566656ee00006d6656665600000000000000000000000000000000000000000000000000000000
de6de6d2000001002d6ed6ed580000855c0000c55900009500560056ee00006d0056005600000000000000000000000000000000000000000000000000000000
6d6de6d2111111112d6ed6d6580000855c0000c55900009500560056ee00006d0056005000000000000000000000000000000000000000000000000000000000
6de6d6d2000100002d6d6ed6588008855cc00cc55990099500560056ee00006d0000000000000000000000000000000000000000000000000000000000000000
6de6de620010000026ed6ed6588008855cc00cc55990099500560056ee00006d0006005600000000000000000000000000000000000000000000000000000000
e6d6de620100000026ed6d6e588888855cccccc55999999500560056e26dee2d0056005600000000000000000000000000000000000000000000000000000000
e6de6d621111111126d6ed6e555555555555555555555555005600562e6dee620056005600000000000000000000000000000000000000000000000000000000
d6de6de2222222222ed6ed6d00000001444544453030303000000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d6d2dee6dee6de2d6d6ed00000010444544450303030300000000000000000000000000000000000000000000000000000000000000000000000000000000
de6d626dee6dee6dee2ed6ed00000100444544450000030000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6d2e6dee6dee6dee62d6d610101010444544550000303000000000000000000000000000000000000000000000000000000000000000000000000000000000
6de2ee6dee6dee6dee6d2ed600010000444544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d2dee6dee6dee6dee6de2d600100000444544450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e26dee6dee6dee6dee6dee2e01000000444544450300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e6dee6dee6dee6dee6dee6210101010445544453030000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555554545450616161664161616161616161616161616161616264545454545950395039503950395454545459595959595959545450616163216c216
1616161616a595959585167216161616264506161626171717171706161616161616161616162645459595459595959595456655555555555555555555555566
66666666666645454517a4a417171717171717171717171717171717171745454545459595039595950395954545454545454545454545454506161616161616
16161626454545454545061616161616264506161626151515151506c416161616161616c4162645459595459595459595955555035503550355035503555566
55555555555545454545959545454545454545454545454545454545454545454545454595959595959595454545454545454545454545454506161616161616
16161626454545454545061616161616161616161616161626454517171717161616161717171745459595459595459595955555550355035503550355035566
555555c3555545454545959595959595959595959595959595959595959595454545454545454545454545454595959595959545454545454506161616161616
16161626454545454545061616161616161616161616c41626454545454506161616162645454545459595959595454545456655035503550355035503555566
5555555555554545454595959595959595959595959595959595959595959545454545454545454545454545459595c395239545454545454506161616161616
16161626454545454545171717171717171717171717171717454545454506161616162645454545459595959595454545456655550355035503550355035566
55555555555545454545454545454545454545454545454545454545459595454545454545454545454545454595959595959545454545454517171717171717
17171717454545454545454545454545454545454545454545454545454506161616162645454545454545454545454545456655555555557255555555555566
55555555555545454545454545454545454545454545454545454545459595959595959595954545454545454545959523954545454545454545454545454545
45454545454545454545454545454545454545454545454545454545454506161616162645454545454545454545454545456655555555555555555555555566
66668666666645454545454545454545454545454545454545454545459595161216169595954545141414141414949494941414141414144545454545454545
45454545141414141414141414141414141445454545454545451414141414161616161414141414454545454545454545456655555555555555555555555566
5555555555554545454545454545341515151515151515151554454545959595959595c395954545041414141414949494941414141414244545454545454545
45454545341515151515151515151515155445454545454545451414141414161616161414141414454545454545454545456655555555555555555555555566
555555555555454545454545454506161616161616c416c416264545459595959595959595954545051515151515848484841515151515254534151515151554
4545454506c416161616161616161616162645454545454545453415151515161616161515151554454545454545454545456655555555555555555555555566
5555555555559595959595959545061616161616161616161626454545454545454545454545454506c416161616161616167416161316264506161622161626
45454545061616161616161616a21616162645454545454545450616161616161616161616161626454545454545454545456655555555555555555555555566
55551616555595959595959595450616161616161616161616264545454545454545454545454545061616161616161616167516161616264506162216161626
4545454506c416161616161616161616162645454545454545450616161616161616161616161626454545454545454545456666666666555566666666666666
55551616555545454534158415151516161616161616161616151515151515151515151515151515061616161616161616167516161216261515221616161626
15151515156464646464161216641616162645454545454545450616161616161616161616161626454545454545454545456666666666555566666666666666
55551616555545454506131616161616161616161616161616161616161616161616161616161616461616167416161216167516161616361616161622030316
16161616161616161664161616641616161515151515151515151516161616161616161616161626454545454545454545456655555555555555555555555566
5555167255554545450616165316164216161616161622161616161616a216161316161616161616461616167516161616167516161616361616161616030316
16161603161616031664161616641616161616161616166216161616161616161616161616161626454545454545454545456655555555555555555555555566
55551616555545454506331616161616161616c21616161616161616161616161616161616161616461616167516167212167516161616361616221616030316
1616161616161616166472161664161616161616331616621616161616161616c216821616161626454545454545454545456655555555555555555555555566
55551616555545454507171717171716161616161616161616171717171717171717171717171717061616167516161616167512161616261717162216161626
17171717171612161664161216641616161616161616166216161616161616161616161616161626454595959595959545456655555555555555555555555566
55551616555545454545454545450616161616221616161616264545454545454545454545454545061616167516161616127616161612264506161616161626
45454545061616161664161616641616161717171717171717171716161616161616161616161626454595959595959545456655555555555555555555555566
55551616555545454545454545450616161616161616161616264545454545454545454545454545060303037516161616161616161616264507171717171727
4545454506161603161662626264161316264545454545454545061616161616161616161616162645459595c395959545456655555555555542555555555566
55551616555545454545454545450616161616161616161616264545454545454545454545454545060303037616161616161616161616264545454545454545
4545454506161616161616161664161616264545454545454545061616161616161616161616162645459595953395954545665555555555c255555555555566
55551616555545454545454545450616161616161616c41616264545454545454545454545454545071717171717161616161717171717274545454545454545
45454545071717171717171717171717172745454545454545450617171717171717171717171726454595959595959545456655555555555555555555555566
55551616555545454545454545450717171717171717171717274545454545454545454545454545454545454506161616162645454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454595959595959545456655555555555555555555555566
55551616555545454545454545454545454545454545454545454545454545454545454545454545454545454506161616162645454545454545454545454545
45454545454545454545454545454545454545454545454545454545454545454545454545454545454545459595454545456655555555555555555555555566
55551616556464646464645545454545454545454545454545454545666666666666666666666666665555454506464646462645456666666666666666666666
66666666666666666666666666666666666666666666666645454545454545454545454545454545454545459595454545456655555555555555555582555566
64555555556464646464645555555566555555555555556666666666665555555555555555555555665555555555161616165555555555555555555555555555
55555555555555555566555555555555552222225555555545454545454545454545454545454545454545459595454545456655555555555555555555555566
64555555555594949494645555555566555555555555556655555555555555555555555555555555665555555555161616165555555555555555555555555555
22555555555555555566555555555555555555555555555545454545454545454545454545454545454545459595454545456666666666555555666666666666
64555555555594555594645555555566551616165555556655555555555555555555555555555555665555555555161616165555555555555555555555555555
55555555555555555555555555555555551616165555555545454545454545454545454545454545454545459595959595956666666666555555666666666666
6455555555729455c394645555555566551616161616161616161616555555555555555555555555665555555555161016165555555555555555552255555555
555555555555555555a2555555555555551663165555555545454545454545454545454545454545454545459595959595958655555555555555555555555566
6494a4949494942323946455555555665516c3161616c21616161616555555555555555555555555865555555555161616165555555555555555555572555555
55555555555555555555555572555555551616165555555545454545454545454545454545454545454545454545454545456655035503035503035503555566
64949494949494232394645555555566551616165555556655555555555555555555555555555555865555555555555555555555555555555555555555555555
2255555555555555556655555555555555555555555555556695959595959595955555555555554545454545454545454545665555235555235555235555c366
64949494949494949494645555555566555555555555556655555555555555555555555555555555665555555555555555555555555555555555555555555555
55555555555555555566555555555555552222225555555586959595959595959555555555c35545454545454545454545456655035503035503035503555566
64646464646464646464645555555566555555555555556655555555555555555555555555555555666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666959595959595959555555555555545454545454545454545456666666666666666666666666666
__gff__
0000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010001010101010101011511150808080808010101000100010115111500080808080100010303030101150000000000000001010100040000000000000000000000
0000010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
6666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666545151515151515151515151515151515151515151515151515151515151515162
6655555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555556655555555555555555566555555555555555555556655555555555555555555555555555555616161555555555555546061616161616161616161616161616260616146464646464646464646616162
6630553055555528555555555555555555555555555555555555555555555555555555555555555555555555555555556655555555555555555566555555555555553c55556655555555555555555555555555555561464646615555555555546061616161616161616161616161616260616146616161616161616146616162
6655305555555555555555555555555555555555555555555555555555555555555555555555555555555555555555556655556666666666666666555566666666666666666655554646555555555555555555556146612361466155555555546061616161616161616161616161616260616146616161346161616146616162
6630553c55235555555523555555552355555555235555555523555555555523555555552355555555555555555555556855556655555555555555555566555555555555556655465523465555555555555555613055464646556130555555546061616161616161616161616161616260616146464661616146464646616162
6655305555555555555555555555555555555555555555555555555555555555555555555555555555555555555555556855556666666666666666555566666666666666666655554646616161616161616161615555555555555561616161546061612861616161616161616161616260616146464661616146464646616162
6630553055555555555555555555555555555555555555555555555555555555555555555555555555555555555555556655555555555555555566555555555555555555556655555561306161306161306161616161616161616161613061656561616161616161616161616161616161616161614661616146464646466162
665530555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555665555555555555555556655555555555555555555665555556161616161616161616161616161276161616161306165656161616161612c616161616161616161616161614661276161616161466162
6655555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555556655556666666666555566555566666666666655556655555561616161616161616161615555555555555561616161546061616161616161616161616161616260616161614661616161616161466162
6666666666666666666666666666666666686866666666666666666666666666666666666666666666666666666666666655555555555566555555555566555555555555556655555561306161555555555555613055464646556130555555546061616161616161616161616161616260616161614646464646616161466162
5555555555555454545454545454545454595954545454545454545454545454545454545454545454545454545454546655555555555566555555555566555555555555556655555561616161555555555555556146612361466155555555546061616161616161616128616161616260616161616161616161616161466162
55555555555554595959595959595959595959545454545454545454545454545454545454545454545454545454545466666666666868666666666666666666666666666666555555616161615555555555555555614646466155555555555460616161616161616161616161616162606161616161612a6161616161466162
5555555555555459595959595959595959595954545454545454545454545454545454545454545454545454545454545555555555555555555555555555555555555555555555555561306161555555555555555555616161555555555555546061616161616161616161616161616260616161616161616161616161466162
5555555555555459594141414141414141414141414141414141414141415454545454545454545454545454545454545555555555555555555555555555555555555555555555555561616161555555555555555555555555555555555555547171717171717171717171717171717160717171717171717171717171717171
5555555555555459595151515151515151515151515151515151515151515454414141414141414141414141415454545555555555555555555555555561616161616161616161616161616161555554545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
5555555555555459596061616161616161616161616161616161616161625454515151515151515151515151515454545555555555555555555555555561616161306161306161306161306161555554545959595959595954545459595959595954545454545454545454545454545454546161616161616161616161615454
55555555555554595960612361616161616161612361616161616137616254546061616161236161616161615a5959583061555561555561555561555561306161616161616161616161616161555554545959595959595954545459595959595954545454595959595959595454545454546161464661616161614646615454
55555555555554595960616161616161616161616161616161616161616254546061616161616161616161615a5959583061555561555561555561555561616155555555555555555555555555555554545459595454595954545459595151494951515154595959595959595454545454546146612346616161466123465454
55555555555554595960616161464646464646464646464646464646466254546061616161616161616161615a5959583061555561275561555561555561616155555555555555555555555555555554515151485151595954545459596061616161616254595954545459595454545454546161464661616161614646615454
5555555555555459596061616146616161466161616161616146616161616161616161616161616161616161625454545555555555555555555555555561306155555555555555555555555555555554606161616162595959595959596061613c61616259595954595959595454595959596161616161616161616161615454
3c55555555555959596061616146612361466123616161616146612a61616161612461616161616161616161625454545555555555555555555555555561616155555555555555555555555555555554606132326162595959595959596061616161615a59595954595959595454595959596161616161612c6161613c615454
55555555555559595960616161466161614661616161616161466161616161616161616161612c6161616161625454545555555555555555555555555561616155555555555555555555555555555554606132326162545454545454546061616161616254545454595954545454595954546161616161616161616161615454
5555555555555454546061616146616161616161614661616146616161625454606161616161616161616161625454545555555555555555555555555561306155555555555555555555555555555554606161616162545454545454547171717171717154545454595959595959595954546161616161616161616161615454
555555555555545454606123614661616161616161466161614661616162545460616161616161616161616162545454666666686866666666666666666161616666666666666868666666666666665471714a4a7171545454545454545454545454545454545454595959595959595954546161464661616161614646615454
5555555555555454546061616146616161616161614661616146616161625454606161616161616161616161625454545454545959545454545454546061616162545454545459595454545454545454545459595454545454545454545454545454545454545454545454545454545454546146612346616161466123465454
5555555555555454546061616146616161466161614646464646616161625454606161616123616161616161625454545454545959545454545454546061306162545454545459595959595959595959595959595454545454545454545454545454545454545454545454545454545454546161464661616161614646615454
55555555555554545460616161616161614661616161616161616161616254547171717171714a4a71717171715454545454545959545454544141416061616162414141545459595959595959595959595959595454545454545441414141414141414141414154545454545454545454545454545454545454545454545454
5555555555555454546061616161616161466123616161616161613361625454545454545454595954545454545454545454545959545454545151516061616151515151545454545454414141414141414141414141414141414141515151515151515151515154545454545454545454545454545454545454545454545454
55555555555554545460616161616161614661616161616161616161616254545454545459595959595959545454545459595959595959545460616161613061616161625454545454545151515151515154515151515151515151514c614c614c614c614c616254545454545454545454545454545454545454545454545454
5555555555555454546061616146464646464646464646464646612361625454545454595930595959305959545454545959595931595954546061616161616161616162545454545454606161616161625460616161616161616161616161616161616161615a59595959545454545454545454545454545454545454545454
55555555555554545460616161466161616161616161616161616161616254545454545930593059305930595454545459593c5959595954546061616161616161616161615a59595958616161616161625460616161612a61616161616161616161616161615a59595959545454545454545454545454545454545454545454
5555555555555454546061616146616161236161616161616161616161625454545454595930593c59305959545454545959595931595954546061616161616161616161225a5959595822616161616162546061616161616161616161616161616161614c616254545959545959595959546666666666666666666666666666
