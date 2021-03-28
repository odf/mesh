module TopologyTests exposing
    ( empty
    , goodFaceList
    , orientationMismatch
    , unpairedOrientedEdge
    )

import Expect
import Test exposing (Test)
import Topology


octahedronFaces : List (List Int)
octahedronFaces =
    [ [ 0, 1, 2 ]
    , [ 1, 0, 5 ]
    , [ 2, 1, 3 ]
    , [ 0, 2, 4 ]
    , [ 3, 5, 4 ]
    , [ 5, 3, 1 ]
    , [ 4, 5, 0 ]
    , [ 3, 4, 2 ]
    ]


empty : Test
empty =
    Test.test "empty"
        (\() ->
            Topology.empty
                |> Expect.all
                    [ Topology.vertices >> Expect.equal []
                    , Topology.edges >> Expect.equal []
                    , Topology.faces >> Expect.equal []
                    ]
        )


goodFaceList : Test
goodFaceList =
    Test.test "goodFaceList"
        (\() ->
            octahedronFaces
                |> Topology.fromOrientedFaces
                |> Result.withDefault Topology.empty
                |> Expect.all
                    [ Topology.vertices
                        >> Expect.equal (List.range 0 5)
                    , Topology.edges
                        >> Expect.equal
                            [ ( 0, 1 )
                            , ( 0, 2 )
                            , ( 0, 4 )
                            , ( 0, 5 )
                            , ( 1, 2 )
                            , ( 1, 3 )
                            , ( 1, 5 )
                            , ( 2, 3 )
                            , ( 2, 4 )
                            , ( 3, 4 )
                            , ( 3, 5 )
                            , ( 4, 5 )
                            ]
                    , Topology.faces
                        >> List.sort
                        >> Expect.equal
                            [ [ 0, 1, 2 ]
                            , [ 0, 2, 4 ]
                            , [ 0, 4, 5 ]
                            , [ 0, 5, 1 ]
                            , [ 1, 3, 2 ]
                            , [ 1, 5, 3 ]
                            , [ 2, 3, 4 ]
                            , [ 3, 5, 4 ]
                            ]
                    , \mesh ->
                        Topology.vertices mesh
                            |> List.map (\v -> ( v, Topology.neighbors v mesh ))
                            |> Expect.equal
                                [ ( 0, [ 1, 2, 4, 5 ] )
                                , ( 1, [ 0, 5, 3, 2 ] )
                                , ( 2, [ 0, 1, 3, 4 ] )
                                , ( 3, [ 1, 5, 4, 2 ] )
                                , ( 4, [ 0, 2, 3, 5 ] )
                                , ( 5, [ 0, 4, 3, 1 ] )
                                ]
                    ]
        )


unpairedOrientedEdge : Test
unpairedOrientedEdge =
    Test.test "unpairedOrientedEdge"
        (\() ->
            octahedronFaces
                |> List.drop 1
                |> Topology.fromOrientedFaces
                |> Expect.err
        )


orientationMismatch : Test
orientationMismatch =
    Test.test "orientationMismatch"
        (\() ->
            octahedronFaces
                |> List.drop 1
                |> (::) [ 0, 2, 1 ]
                |> Topology.fromOrientedFaces
                |> Expect.err
        )
