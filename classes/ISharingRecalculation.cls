/**
 * Created by yanagerasimchuk on 5/30/18.
 */

public interface ISharingRecalculation {
    void removeSharings(Map<Id, List<SharingWrapper>> sharings);
    void addSharings(Map<Id, List<SharingWrapper>> sharings);
}