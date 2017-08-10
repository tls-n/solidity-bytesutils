pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/bytesutils.sol";



contract TestBytesutils {
    using bytesutils for *;


    function abs(int x) private returns (int) {
        if(x < 0)
            return -x;
        return x;
    }

    function sign(int x) private returns (int) {
        return x/abs(x);
    }

    function myassertEq(bytes memory _a, bytes memory _b) {
      Assert.equal(_a.length, _b.length, "Lengths are different.");
      for(uint i=0; i<_a.length; i++) {
        Assert.equal(_a[i], _b[i], "A character is different.");
      }
    }

    function myassertEq(string memory a, string memory b) {
      bytes memory _a = bytes(a);
      bytes memory _b = bytes(b);
      myassertEq(_a, _b);
    }



    function assertEq(bytesutils.slice a, bytesutils.slice b) internal {
        myassertEq(a.toBytes(), b.toBytes());
    }

    function assertEq(bytesutils.slice a, string b) internal {
        myassertEq(a.toString(), b);
    }

    function assertEqB(bytesutils.slice a, bytes b) internal {
        myassertEq(a.toBytes(), b);
    }


    function testZero() returns (bool){
        bytes memory a = "";
//        if(a.toSlice().len() != 0){
//            Assert.equal(0, 1, "Error Message");
//        }
        uint expected = 0;
        Assert.equal(a.toSlice().len(), expected, "Error Message");
    }


    function testToSliceB32() {
        bytes memory x = "foobar";
        assertEq(bytes32("foobar").toSliceB32(), x.toSlice());
    }


    function testCopy() {
        bytes memory test = "Hello, world!";
        var s1 = test.toSlice();
        var s2 = s1.copy();
        s1._len = 0;
        Assert.equal(s2._len, test.length, "Error Message");
    }


    function testLen() {
        bytes memory test = "";
        Assert.equal(test.toSlice().len(), 0, "Error Message");
        test = "Hello, world!";
        Assert.equal(test.toSlice().len(), 13, "Error Message");
        test = "\x00\x01\x02\x03\x04";
        Assert.equal(test.toSlice().len(), 5, "Error Message");
        test = "test\r\ntest\r\n";
        Assert.equal(test.toSlice().len(), 12, "Error Message");
    }


    function testEmpty() {
        bytes memory test = "";
        Assert.isTrue(test.toSlice().empty(), "Error Message");
        test = "\x00";
        Assert.isFalse(test.toSlice().empty(), "Error Message");
    }

    function testEquals() {
        bytes memory test = "";
        bytes memory test1 = "foo";
        bytes memory test2 = "foo";
        bytes memory test3 = "bar";  
        Assert.isTrue(test.toSlice().equals(test.toSlice()), "Error Message");
        Assert.isTrue(test1.toSlice().equals(test2.toSlice()), "Error Message");
        Assert.isTrue(test3.toSlice().equals(test3.toSlice()), "Error Message");
        Assert.isFalse(test2.toSlice().equals(test3.toSlice()), "Error Message");
    }


    function testNextRune() {
        bytes memory test = "\xffa\x00\x20h";
        var s = test.toSlice();
        assertEqB(s.nextRune(), "\xff");
        assertEqB(s, "a\x00\x20h");
        assertEqB(s.nextRune(), "a");
        assertEqB(s, "\x00\x20h");
        assertEqB(s.nextRune(), "\x00");
        assertEqB(s, "\x20h");
        assertEqB(s.nextRune(), "\x20");
        assertEqB(s, "h");
        assertEqB(s.nextRune(), "h");
        assertEqB(s, "");
        assertEqB(s.nextRune(), "");
    }

    function testOrd() {
        bytes memory test = "a";
        Assert.equal(test.toSlice().ord(), 0x61, "Error Message");
        test = "i";
        Assert.equal(test.toSlice().ord(), 0x69, "Error Message");
        test = "\x01";
        Assert.equal(test.toSlice().ord(), 0x01, "Error Message");
        test = "\x42";
        Assert.equal(test.toSlice().ord(), 0x42, "Error Message");
        test = "\xff";
        Assert.equal(test.toSlice().ord(), 0xff, "Error Message");
    }

    function testCompare() {
        bytes memory test0 = "foobie";
        bytes memory test1 = "foobif";
        bytes memory test2 = "foobid";
        bytes memory test3 = "foobies";
        bytes memory test4 = "foobi";
        bytes memory test5 = "doobie";
        bytes memory test6 = "01234567890123456789012345678901";
        bytes memory test7 = "012345678901234567890123456789012";

        Assert.equal(test0.toSlice().compare(test0.toSlice()), 0, "Error Message");
        Assert.equal(sign(test0.toSlice().compare(test1.toSlice())), -1, "Error Message");
        Assert.equal(sign(test0.toSlice().compare(test2.toSlice())), 1, "Error Message");
        Assert.equal(sign(test0.toSlice().compare(test3.toSlice())), -1, "Error Message");
        Assert.equal(sign(test0.toSlice().compare(test4.toSlice())), 1, "Error Message");
        Assert.equal(sign(test0.toSlice().compare(test5.toSlice())), 1, "Error Message");
        Assert.equal(sign(test6.toSlice().compare(test7.toSlice())), -1, "Error Message");
    }

    function testCompare2() {
        bytes memory test8 = "foo.bar";
        bytes memory test9 = ".";
        bytes memory test10 = "foo";

        Assert.equal(test8.toSlice().split(test9.toSlice()).compare(test10.toSlice()), 0, "Error Message");
    }

    function testStartsWith() {
        bytes memory test0 = "foobar";
        bytes memory test1 = "foo";
        bytes memory test2 = "oob";
        bytes memory test3 = "";
        var s = test0.toSlice();
        Assert.isTrue(s.startsWith(test1.toSlice()), "Error Message");
        Assert.isFalse(s.startsWith(test2.toSlice()), "Error Message");
        Assert.isTrue(s.startsWith(test3.toSlice()), "Error Message");
        Assert.isTrue(s.startsWith(s.copy().rfind(test1.toSlice())), "Error Message");
    }

    function testBeyond() {
        bytes memory test0 = "foobar";
        bytes memory test1 = "foo";
        bytes memory test2 = "bar";
        var s = test0.toSlice();
        assertEqB(s.beyond(test1.toSlice()), test2);
        assertEqB(s, test2);
        assertEqB(s.beyond(test1.toSlice()), test2);
        assertEqB(s.beyond(test2.toSlice()), "");
        assertEqB(s, "");
    }

    function testEndsWith() {
        bytes memory test0 = "foobar";
        bytes memory test1 = "oba";
        bytes memory test2 = "bar";
        bytes memory test3 = "";
        var s = test0.toSlice();
        Assert.isTrue(s.endsWith(test2.toSlice()), "Error Message");
        Assert.isFalse(s.endsWith(test1.toSlice()), "Error Message");
        Assert.isTrue(s.endsWith(test3.toSlice()), "Error Message");
        Assert.isTrue(s.endsWith(s.copy().find(test2.toSlice())), "Error Message");
    }

}
