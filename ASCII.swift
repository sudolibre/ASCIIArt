//
//  ASCII.swift
//  
//
//  Created by Jonathon Day on 11/28/16.
//
//

import Foundation

var spacing = ""
func distance(x: Int) {
    for i in 0...x {
        spacing = spacing + " "
    }
}

func walk(frame: Int) {
    if frame == 1 {
print(spacing + "             ooo   ")
print(spacing + "           oo   oo")
print(spacing + "          o       o")
print(spacing + "           oo   oo")
print(spacing + "             ooo")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "            //||\\")
print(spacing + "           // || \\")
print(spacing + "          //  ||  \\")
print(spacing + "         (-)  ||   (-)")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "            //  \\")
print(spacing + "           //    \\")
print(spacing + "          //      \\")
print(spacing + "         //        \\")
print(spacing + "        (--)       (--)")
}
    else if frame == 2 {
print(spacing + "             ooo   ")
print(spacing + "           oo   oo")
print(spacing + "          o       o")
print(spacing + "           oo   oo")
print(spacing + "             ooo")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "            //||\\")
print(spacing + "           // || \\")
print(spacing + "           // || \\")
print(spacing + "           (-)|| (-)")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "            //  \\")
print(spacing + "            //   \\")
print(spacing + "            //   \\")
print(spacing + "           //     \\")
print(spacing + "          (--)    (--)")
}

    else if frame == 3 {
print(spacing + "             ooo   ")
print(spacing + "           oo   oo")
print(spacing + "          o       o")
print(spacing + "           oo   oo")
print(spacing + "             ooo")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "            //||\\")
print(spacing + "            ||||||")
print(spacing + "            ||||||")
print(spacing + "           (-)||(-)")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "              ||")
print(spacing + "            //  \\")
print(spacing + "            ||   ||")
print(spacing + "            ||   ||")
print(spacing + "            ||   ||")
print(spacing + "           (--) (--)")
}
    
    else if frame == 4 {
        print(spacing + "             ooo   ")
        print(spacing + "           oo   oo")
        print(spacing + "          o       o")
        print(spacing + "           oo   oo")
        print(spacing + "             ooo")
        print(spacing + "              ||")
        print(spacing + "              ||")
        print(spacing + "            //||\\")
        print(spacing + "           // || \\")
        print(spacing + "           // || \\")
        print(spacing + "           (-)|| (-)")
        print(spacing + "              ||")
        print(spacing + "              ||")
        print(spacing + "              ||")
        print(spacing + "            //  \\")
        print(spacing + "            //   \\")
        print(spacing + "            //   \\")
        print(spacing + "           //     \\")
        print(spacing + "          (--)    (--)")
    }
}


var n = 1
func walking(times: Int) {
    if times == 20 {
        spacing = ""
    }
    walk(frame: n)
    sleep(1)
    print("\u{001B}[2J")
    if n < 4 {
        n += 1
        } else {
        n = 1
    }
    distance(x: 3)
    walking(times: times + 1)
}

walking(times: 1)

