pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/bytesutils.sol";



contract TestBytesutils2 {
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
      Assert.equal(_a.length, _b.length, "Error Message");
      for(uint i=0; i<_a.length; i++) {
        Assert.equal(_a[i], _b[i], "Error Message");
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


    function testUntil() {
        bytes memory test0 = "foobar";
        bytes memory test1 = "foo";
        bytes memory test2 = "bar";
        bytes memory test3 = "";
        bytesutils.slice memory s = test0.toSlice();
        assertEqB(s.until(test2.toSlice()), test1);
        assertEqB(s, test1);
        assertEqB(s.until(test2.toSlice()), test1);
        assertEqB(s.until(test1.toSlice()), test3);
        assertEqB(s, test3);
    }

    function testFind() {
        bytes memory test0 = "abracadabra";
        bytes memory test1 = "bra";
        bytes memory test2 = "bracadabra";
        bytes memory test3 = "rab";
        bytes memory test4 = "12345";
        bytes memory test5 = "123456";
        bytes memory test6 = "5";
        bytes memory test7 = "";
        assertEqB(test0.toSlice().find(test0.toSlice()), test0);
        assertEqB(test0.toSlice().find(test1.toSlice()), test2);
        Assert.isTrue(test0.toSlice().find(test3.toSlice()).empty(), "Error Message");
        Assert.isTrue(test4.toSlice().find(test5.toSlice()).empty(), "Error Message");
        assertEqB(test4.toSlice().find(test7.toSlice()), test4);
        assertEqB(test4.toSlice().find(test6.toSlice()), test6);
    }

    function testRfind() {
        bytes memory test0 = "abracadabra";
        bytes memory test1 = "bra";
        bytes memory test2 = "cad";
        bytes memory test3 = "abracad";
        bytes memory test4 = "12345";
        bytes memory test5 = "123456";
        bytes memory test6 = "1";
        bytes memory test7 = "";
        assertEqB(test0.toSlice().rfind(test1.toSlice()), test0);
        assertEqB(test0.toSlice().rfind(test2.toSlice()), test3);
        Assert.isTrue(test4.toSlice().rfind(test5.toSlice()).empty(), "Error Message");
        assertEqB(test4.toSlice().rfind(test7.toSlice()), test4);
        assertEqB(test4.toSlice().rfind(test6.toSlice()), test6);
    }

    function testSplit() {
        //var x = "foo->bar->baz";
        var s = "foo->bar->baz".toSlice();
        var delim = "->".toSlice();
        assertEq(s.split(delim), "foo");
        assertEq(s, "bar->baz");
        assertEq(s.split(delim), "bar");
        assertEq(s.split(delim), "baz");
        Assert.isTrue(s.empty(), "Error Message");
        assertEq(s.split(delim), "");
        assertEq(".".toSlice().split(".".toSlice()), "");
    }

    function testRsplit() {
        var s = "foo->bar->baz".toSlice();
        var delim = "->".toSlice();
        assertEq(s.rsplit(delim), "baz");
        assertEq(s.rsplit(delim), "bar");
        assertEq(s.rsplit(delim), "foo");
        Assert.isTrue(s.empty(), "Error Message");
        assertEq(s.rsplit(delim), "");
    }

    function testCount() {
        Assert.equal("1121123211234321".toSlice().count("1".toSlice()), 7, "Error Message");
        Assert.equal("ababababa".toSlice().count("aba".toSlice()), 2, "Error Message");
    }

    function testContains() {
        Assert.isTrue("foobar".toSlice().contains("f".toSlice()), "Error Message");
        Assert.isTrue("foobar".toSlice().contains("o".toSlice()), "Error Message");
        Assert.isTrue("foobar".toSlice().contains("r".toSlice()), "Error Message");
        Assert.isTrue("foobar".toSlice().contains("".toSlice()), "Error Message");
        Assert.isTrue("foobar".toSlice().contains("foobar".toSlice()), "Error Message");
        Assert.isFalse("foobar".toSlice().contains("s".toSlice()), "Error Message");
    }

    function testConcat() {
        myassertEq("foo".toSlice().concat("bar".toSlice()), "foobar");
        myassertEq("".toSlice().concat("bar".toSlice()), "bar");
        myassertEq("foo".toSlice().concat("".toSlice()), "foo");
    }

    function testJoin() {
        var parts = new bytesutils.slice[](4);
        parts[0] = "zero".toSlice();
        parts[1] = "one".toSlice();
        parts[2] = "".toSlice();
        parts[3] = "two".toSlice();

        myassertEq(" ".toSlice().join(parts), "zero one  two");
        myassertEq("".toSlice().join(parts), "zeroonetwo");

        parts = new bytesutils.slice[](1);
        parts[0] = "zero".toSlice();
        myassertEq(" ".toSlice().join(parts), "zero");
    }

    function testSha256() {
        var s = "foo->bar->baz".toSlice();
        var delim = "->".toSlice();
        var x = s.split(delim);
        Assert.equal(x.slicesha256(), 0x2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae, "Error Message");
        x = s.split(delim);
        Assert.equal(x.slicesha256(), 0xfcde2b2edba56bf408601fb721fe9b5c338d10ee429ea04fae5511b68fbf8fb9, "Error Message");
        x = "test".toSlice();
        Assert.equal(x.slicesha256(), 0x9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08, "Error Message");
        
    }

    function testSliceOffset() {
        bytes memory test1 = "foo";
        bytes memory test2 = "foo";
        bytes memory test3 = "oo";  
        bytes memory test4 = "foofoo";
        assertEqB(test1.toSlice(1), test3);
        Assert.isTrue(test1.toSlice(1).equals(test3.toSlice()), "Error Message");
        Assert.isTrue(test1.toSlice(1).equals(test2.toSlice(1)), "Error Message");
        Assert.isTrue(test4.toSlice(3).equals(test1.toSlice()), "Error Message");
        Assert.isFalse(test2.toSlice(1).equals(test2.toSlice(2)), "Error Message");
        myassertEq(test2.toSlice(1).toBytes(), test3);
        myassertEq(test4.toSlice(1).split("f".toSlice()).toBytes(), test3);
    }


    function testLong() {
        bytes memory proof='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        assertEqB(proof.toSlice(), proof);
    }


    function testTruncate(){
        bytes memory test1 = "foo";
        bytes memory test2 = "test123";
        bytes memory test3 = "test";
        bytes memory test4 = "foobar";
        bytes memory test5 = "test1";
        var s = test4.toSlice();    
        s.truncate(3);
        assertEqB(s, test1);
        assertEqB(test2.toSlice().truncate(5), test5);
        var x = test2.toSlice();
        assertEqB(x.truncate(5), test5);
        assertEqB(x.truncate(4), test3);
    }

}
